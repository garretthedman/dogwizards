//
//  LevelScene.swift
//  DogWizards Shared
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A scene the presents a LevelModel
class LevelScene: SKScene {

    // MARK: - Cast

    /// Object for tracking the cast path a user must follow
    private struct CastPathTarget {
        /// The card that is being targeted
        let card: Card
        /// The overlay that should be shown when the user drags into the frame
        let overlay: SKShapeNode
        /// The exact frame target. This could be the top or bottom half of the card when the card has two units
        let frame: CGRect
        /// If this target being hit indicates the whole card has been dragged over (e.g. a user dragging over the top half of the card requires them to have already hit the bottom half. This would indicate a full cast)
        let isFinalCardPoint: Bool
    }

    // MARK: - Sprites

    /// The current max z position of any sprite on screen
    private var maxZPosition = CGFloat(1)

    /// The far left start card sprite
    private let startCard: OneUnitCard

    private let startCardHolder: CardHolder

    /// The cast button
    private let castButton = Button(text: "Perform!")

    /// The tray that holds the user's cards to cast. Each slot in the tray has a visual affordance indicating a card can be dropped.
    private let cardHolderTray: CardHolderTray

    /// Top label indicating current cast result
    private let castResultLabel = SKLabelNode(text: "X")

    /// Goal label
    private let castGoalLabel = SKLabelNode(text: "")

    private let castGoalLabelBackgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 40), cornerRadius: 10)

    /// Node which contains all the overlays from the cast targets
    private let castOverlayNode = SKNode()

    /// All the card sprites on screen
    private var cards = [Card]()
    /// All the start unit buttons that are shown when the user wants to change the start card
    private var startUnitButtons = [Button]()

    /// All the background images for the game
    let streetBackground = SKSpriteNode()

    let feedbackBackgroundSprite = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 100, height: 40), cornerRadius: 10)
    let feedbackLabel = SKLabelNode()

    var performBackground: SKShapeNode?
    var hmmBackground: SKShapeNode?

    // MARK: - Gesture Tracking

    /// Used to track the cards the user is panning accross the screen
    private var panGestureRecognizerData = [GameViewPanGestureRecognizer: PanGestureRecognizerMetadata]()
    /// An array (w/ a specific order) of the targets the user should hit when casting
    private var castTargets = [CastPathTarget]()

    // MARK: - Properties

    /// The model to represent
    private let model: LevelModel

    private let colors: [SKColor] = [
        .orange,
        .yellow,
        .green,
        .blue,
        .magenta
    ]
    
    private var lastHolder: CardHolder
    private var currentHolder: CardHolder

    /// Bool indicating if in casting more
    private var isCasting = false {
        didSet {
            // Cancel all active gestures
            panGestureRecognizerData = [:]
            // Update the button label
            if (isCasting){
                castButton.label.text = "Stop"
//                castButton.label.fontColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            } else {
                castButton.label.text = "Perform!"
                castButton.label.fontColor = .black
            }
            //castButton.label.text = isCasting ? "X" : "PERFORM"

            // Fade out any cards not part of the cast
            let alpha: CGFloat = isCasting ? 0.25 : 1.0
            cards.forEach { card in
                // Cards not in the tray don't have an index in the cast model
                if model.castModel.index(of: card.model) == nil {
                    card.run(.fadeAlpha(to: alpha, duration: 0.2))
                }
            }

            hmmBackground?.run(.fadeAlpha(to: alpha, duration: 0.2))
//            backgroundColor = Design.backgroundColor.withAlphaComponent(alpha)

            if !isCasting {
                model.castModel.resetCardCastStates()
            }
        }
    }

    /// Bool tracking if showing options for the start card
    var isShowingStartUnitOptions = false {
        didSet {
            if isShowingStartUnitOptions {
                showStartUnitOptions()
            } else {
                hideStartUnitOptions()
            }
        }
    }

    var lastCorrectlyCastUnit: Unit?

    private let wiggleAction = SKAction.sequence([
        .repeat(.sequence([
            .rotate(toAngle: CGFloat.pi / 16, duration: 0.1),
            .rotate(toAngle: -CGFloat.pi / 16, duration: 0.1)]), count: 2),
        .rotate(toAngle: 0.0, duration: 0.1)
    ])

    let overlayNode = SKNode()
    var isInFalsePathMode = false

    // MARK: - Initialization

    init(for model: LevelModel) {
        self.model = model

        // create a tray that can hold the max amount of cards supported in this level's cast
        cardHolderTray = CardHolderTray(holderCount: model.castModel.cards.count)
        // create the far left card indicating the start unit
        startCard = OneUnitCard(model: CardModel(values: .one(model.castModel.startMeasurement)))
        startCardHolder = CardHolder()
        lastHolder = startCardHolder
        currentHolder = startCardHolder
        
        super.init(size: Design.sceneSize)
        scaleMode = .aspectFit
        backgroundColor = Design.backgroundColor
        anchorPoint = CGPoint(x: 0, y: 0)
        
        // add images for the background
        streetBackground.texture = SKTexture(imageNamed: "rockBack")
        streetBackground.position = CGPoint(x: Design.sceneSize.width/2, y: Design.sceneSize.height/1.2+60)
        streetBackground.size = CGSize(width: 560, height: 249)
        addChild(streetBackground)


        feedbackLabel.text = "MATCH"
        feedbackLabel.fontColor = .white
        feedbackLabel.fontSize = 20
        feedbackLabel.fontName = "AvenirNext-Medium"

        feedbackBackgroundSprite.addChild(feedbackLabel)
        feedbackBackgroundSprite.fillColor = .blue

        feedbackBackgroundSprite.alpha = 0
        feedbackBackgroundSprite.position = CGPoint(x: 200, y: 200)
        feedbackLabel.position = CGPoint(x: feedbackBackgroundSprite.frame.width / 2, y: feedbackBackgroundSprite.frame.height / 4)
        addChild(feedbackBackgroundSprite)

        let performBackground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: cardHolderTray.frame.width + startCard.frame.width + 100, height: frame.height / 2 + 100), cornerRadius: 30)
        performBackground.fillColor = Design.backgroundColor
        performBackground.strokeColor = .clear
        performBackground.position = CGPoint(x: frame.width / 2 - performBackground.frame.width / 2, y: frame.height / 2 - 100)
        performBackground.zPosition = -1
        addChild(performBackground)
        self.performBackground = performBackground


        let hmmBackground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        hmmBackground.fillColor = Design.backgroundColor
        hmmBackground.strokeColor = .clear
        hmmBackground.position = CGPoint(x: frame.width / 2 - hmmBackground.frame.width / 2, y: frame.height / 2  - hmmBackground.frame.height / 2)
        hmmBackground.zPosition = -2
        addChild(hmmBackground)
        self.hmmBackground = hmmBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Scene Configuration

    override func didMove(to view: SKView) {
        run(SKAction.sequence([.fadeOut(withDuration: 0), .wait(forDuration: 0.25), .fadeIn(withDuration: 1.0), .run {
            self.backgroundColor = .clear
            }]))
        configureCardHolderTray()
        configureCards()

        model.castModel.didUpdate = modelUpdated
    }

    // one time setup of the tray and all the sprites whose position depends on it
    func configureCardHolderTray() {
        // slightly offset x to accommodate start card
        let xPosition = size.width / 2
            - cardHolderTray.size.width / 2
            + (Design.cardHolderSizeWidth + Design.cardHolderPaddingSize) / 2

        cardHolderTray.position = CGPoint(x: xPosition,
                                          y: size.height / 1.9)
        addChild(cardHolderTray)

        // position large result label at top of screen
        castResultLabel.text = "?"
        castResultLabel.fontColor = .black
        castResultLabel.fontSize = 100
        castResultLabel.fontName = "AvenirNext-Medium"
        castResultLabel.position = CGPoint(x: size.width / 2,
                                           y: cardHolderTray.position.y + cardHolderTray.size.height+130)
        addChild(castResultLabel)


        castGoalLabelBackgroundNode.position = CGPoint(x: size.width / 2 - castGoalLabelBackgroundNode.frame.width / 2,
                                                       y: cardHolderTray.position.y + cardHolderTray.size.height+castGoalLabelBackgroundNode.frame.height - 10)
        addChild(castGoalLabelBackgroundNode)

        // position goal label under result label
        castGoalLabel.text = "Goal: " + model.endUnit.displayString
        castGoalLabel.fontColor = .black
        castGoalLabel.fontSize = 30
        castGoalLabel.fontName = "AvenirNext-Medium"
        castGoalLabel.position = CGPoint(x: size.width / 2,
                                         y: cardHolderTray.position.y + cardHolderTray.size.height+40)
        addChild(castGoalLabel)

        // position cast button under tray
        castButton.position = CGPoint(x: size.width / 2,
                                      y: cardHolderTray.position.y - Design.buttonHeight / 2 - 25 )
        addChild(castButton)


        // position start card to left of tray
        startCard.position = CGPoint(x: cardHolderTray.position.x - Design.cardHolderSizeWidth / 2 - Design.cardHolderPaddingSize,
                                     y: cardHolderTray.position.y + (Design.cardHolderSizeWidth * Design.cardHolderSizeRatio) / 2)
        addChild(startCard)

        startCardHolder.color = .clear
        startCardHolder.colorBlendFactor = 1
        startCardHolder.position = startCard.position
        startCardHolder.zPosition = startCard.zPosition - 1
        addChild(startCardHolder)

        // create buttons for possible start units (hidden to start)
        for value in model.startValues {
            if (value.unit != .start){
                let button = Button(text: value.unit.displayString)
                button.zPosition = -1
                button.alpha = 0.0
                button.position = CGPoint(x: startCard.position.x,
                                          y: startCard.position.y)
                addChild(button)
                startUnitButtons.append(button)
            }else {
                print("Had start!")
                print(value.displayString)
            }
        }
        addChild(castOverlayNode)



        let bla = Design.cardHolderSizeWidth + Design.cardHolderPaddingSize

        for (index, _) in cardHolderTray.holders.enumerated() {
            let diagonal = SKSpriteNode(texture: SKTexture(imageNamed: "LineDiagonal"), size: CGSize(width: Design.cardHolderSizeWidth + Design.cardHolderPaddingSize, height: 53.7 * 1.5))
            diagonal.position = CGPoint(x: bla / 2 + bla * CGFloat(index), y: 0)
            overlayNode.addChild(diagonal)

            let straight = SKSpriteNode(texture: SKTexture(imageNamed: "LineStraight"), size: CGSize(width: 11.7 * 1.5, height: 53.7 * 1.5))
            straight.position = CGPoint(x: bla + bla * CGFloat(index), y: 0)
            overlayNode.addChild(straight)
        }

        addChild(overlayNode)

        overlayNode.alpha = 0.0
        overlayNode.position = CGPoint(x: startCard.position.x, y: startCard.position.y)
        overlayNode.zPosition = 1000000
    }

    /// one time setup of the card sprites
    func configureCards() {
        let cardSize = Design.cardSizeWidth + Design.cardPaddingSize
        let width = cardSize * CGFloat(model.deck.count - 1)
        let xOffset = size.width / 2 - width / 2
        for (index, cardModel) in model.deck.enumerated() {
            let card = TwoUnitCard(model: cardModel)
            let position = CGPoint(x: xOffset + cardSize * CGFloat(index), y: 200)
            card.position = position
            card.zPosition = newMaxZPosition()
            addChild(card)
            cards.append(card)
        }
    }

    /// generate a new z position on top of all other elements
    func newMaxZPosition() -> CGFloat {
        maxZPosition += 0.01
        return maxZPosition
    }

    // MARK: - Start Unit Selection

    /// show the start unit option buttons
    func showStartUnitOptions() {
        Logging.shared.log(event: .startCardOptionsViewed)
        for (index, button) in startUnitButtons.enumerated() {

            //position under the start card
            /*let position =  CGPoint(x: startCard.position.x,
             y: startCard.position.y - startCard.size.height - (10 + Design.buttonHeight) * CGFloat(index))*/
            
            let position = CGPoint(x: startCard.position.x - Design.buttonWidth + 10, y: startCard.position.y + (startCard.size.height/2 - 40) - (10 + Design.buttonHeight) * CGFloat(index))
            
            button.run(.group([
                .fadeAlpha(to: 1.0, duration: AnimationDuration.startButtonMove),
                .move(to: position, duration: AnimationDuration.startButtonMove)])
            )
        }
    }

    /// hide the start unit option buttons
    func hideStartUnitOptions() {
        for button in startUnitButtons {
            let position =  CGPoint(x: startCard.position.x,
                                    y: startCard.position.y)
            button.run(.group([
                .fadeAlpha(to: 0.0, duration: AnimationDuration.startButtonMove),
                .move(to: position, duration: AnimationDuration.startButtonMove)])
            )
        }
    }

    // MARK: - Model

    /// update the interface in response to a model update
    func modelUpdated(update: CastModel.Update) {
        switch update {
        case .shift:
            // the model forced the cards to shift (e.g. cast button was pressed with empty slots)
            for (index, cardModel) in model.castModel.cards.enumerated() {
                guard let cardModel = cardModel,
                    let card = cards.filter({ $0.model == cardModel }).first else { continue }

                let newPosition = convert(cardHolderTray.holders[index].position, from: cardHolderTray)
                let diff = card.position.x - newPosition.x
                if diff == 0 {
                    continue
                }

                let magnitude = Design.cardShiftRotation
                let angle = diff > 0 ? magnitude : -magnitude

                let duration = AnimationDuration.cardShift
                let group: [SKAction] = [
                    .move(to: newPosition, duration: duration),
                    .sequence([
                        .rotate(toAngle: angle, duration: duration / 2),
                        .rotate(toAngle: 0, duration: duration / 2)
                    ]),
                    .sequence([
                        .scale(to: Design.cardShiftScale, duration: duration / 2),
                        .scale(to: 1.0, duration: duration / 2)
                    ])
                ]

                card.run(.group(group))
            }
        case .castResult(let result):
            // a new cast result was created

            let text = result?.displayString ?? "?"
            let isDiff = castResultLabel.text != text

            if isCasting && isDiff {
                // if in casting mode and new result, do an animation
                let resultAction = SKAction.sequence([
                    .group([
                        .scale(to: 0.2, duration: 0.1),
                        .fadeAlpha(to: 0.2, duration: 0.1)
                    ]),
                    .run {
                        self.castResultLabel.text = text
                    },
                    .group([
                        .scale(to: 1.0, duration: 0.1),
                        .fadeAlpha(to: 1.0, duration: 0.1)
                    ])
                ])
                castResultLabel.run(resultAction)

            } else {
                castResultLabel.text = text
            }
        }
    }

    // MARK: - Gesture Recognizers


    /// Grabs a card at a point on screen
    ///
    /// - Parameters:
    ///   - point: The point to check
    ///   - inset: The inset to add to each card's frame, enabling a small card to have a larger target area
    /// - Returns: the top most card (if any) at that position
    func card(at point: CGPoint, inset: CGFloat = 0.0) -> Card? {
        guard let card = cards.sorted(by: { lhs, rhs -> Bool in
            return lhs.zPosition > rhs.zPosition
        }).first(where: { card -> Bool in
            return card.frame.insetBy(dx: inset, dy: inset).contains(point)
        }) else { return nil }
        return card
    }

    /// called when a tap is detected
    func tapGestureRecognizerFired(_ gestureRecognizer: GameViewTapGestureRecognizer) {
        guard let view = self.view else { return }

        _cleanFills()

        // the location of the tap in the game scene
        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))
        
        if let card = card(at: adjustedLocation) as? TwoUnitCard, !isCasting {
            // The tap was on a card while not casting

            let inset = -Design.cardFlipButtonCushion
            let frame = card.flipButton.frame.insetBy(dx: inset, dy: inset)

            // check if the tap was on the flip button
            if frame.contains(convert(adjustedLocation, to: card)) {
                card.model.flip()
                return
            }
        } else if castButton.frame.contains(adjustedLocation) || (!(performBackground?.frame.contains(adjustedLocation) ?? true) && isCasting) {
            // The tap was on the cast button

            // toggle the casting mode state
            isCasting.toggle()

            if isCasting {
                // inform the cast model to shift the cards
                model.castModel.prepareForCast()
            }

            // hide start card options
            isShowingStartUnitOptions = false
            return
        } else if startCard.frame.contains(adjustedLocation), !isCasting {
            // the start card was tapped while not casting

            // toggle the visibility of the start unit option buttons
            isShowingStartUnitOptions.toggle()
            return
        } else if !isCasting {
            // not casting

            // check if the tap was on any of the start unit option buttons
            for (index, button) in startUnitButtons.enumerated() {
                if button.frame.contains(adjustedLocation) {

                    model.castModel.resetCardCastStates()
                    
                    // get the unit at that index
                    let startValue = model.startValues[index+1]
                    // update the cast model
                    model.castModel.startMeasurement = startValue
                    // update the card model
                    startCard.model.values = .one(startValue)
                    // update the goal image
                    modelUpdated(update: .castResult(model.castModel.startMeasurement))
                    // trigger a ui update
                    startCard.updateLabels()
                    // hide the start unit option buttons
                    isShowingStartUnitOptions = false

                    Logging.shared.log(event: .startCardChange, description: startValue.unit.displayString)
                    break
                }
            }
        }
    }

    // a pan gesture recognizer updates
    func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        guard let view = self.view else { return }

        if isCasting {
            // if casting, do this other thing
            processPanGestureRecognizerFiredWhileCasting(gestureRecognizer)
            return
        }

        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))
        if gestureRecognizer.state == .began {
            // if the gesture is starting, make sure there is a card under the user's finger
            guard let card = card(at: adjustedLocation) as? TwoUnitCard else {
                panGestureRecognizerData[gestureRecognizer] = nil
                return
            }

            // save the card and the user's location
            let data = PanGestureRecognizerMetadata(card: card, lastLocation: adjustedLocation)
            panGestureRecognizerData[gestureRecognizer] = data

            _cleanFills()
        }

        // make sure we have info on the gesture's card and location
        guard let gesture = panGestureRecognizerData[gestureRecognizer] else { return }

        // get the diff in user touch location since the last update and move the card by that amount
        let diff = adjustedLocation - gesture.lastLocation
        gesture.card.position = gesture.card.position + diff
        panGestureRecognizerData[gestureRecognizer]?.lastLocation = adjustedLocation

        let trayPoint = convert(gesture.card.position, to: cardHolderTray)
        switch gestureRecognizer.state {
        case .began:
            // if this card was in the tray, remove it from the card model
            if cardHolderTray.holders.first(where: { $0.frame.contains(trayPoint) }) != nil {
                model.castModel.pickUp(card: gesture.card)
            }
            // move card to front
            gesture.card.zPosition = newMaxZPosition()

            // animate card pick up
            let group: [SKAction] = [
                .fadeAlpha(to: Design.cardPickUpAlpha, duration: AnimationDuration.cardPickUp),
                .scale(to: Design.cardPickUpScale, duration: AnimationDuration.cardPickUp)
            ]
            gesture.card.run(.group(group))

        case .changed:
            for (index, cardHolder) in cardHolderTray.holders.enumerated() where cardHolder.frame.contains(trayPoint) {
                // the gesture is now over a holder in the card tray
                let holderPoint = convert(cardHolder.position, from: cardHolderTray)
                let cardDiff = gesture.card.position.x - holderPoint.x
                let direction: Direction = cardDiff > 0 ? .left : .right

                // tell the model to clear the holder benath the user's drag
                model.castModel.prepareForDrop(at: index, from: direction)
                break
            }
        case .ended:
            for (index, cardHolder) in cardHolderTray.holders.enumerated() where cardHolder.frame.contains(trayPoint) {
                let holderPoint = convert(cardHolder.position, from: cardHolderTray)

                // tell the model the user dropped a card in the tray
                if model.castModel.drop(card: gesture.card.model, at: index) {
                    // if the drop was successful (the space was empty), animate the card to the center of the holder
                    let action = SKAction.move(to: holderPoint,
                                               duration: AnimationDuration.cardMoveToHolder)
                    gesture.card.run(action)
                }
                break
            }

            // run the put down animation
            let group: [SKAction] = [
                .fadeAlpha(to: 1.0, duration: AnimationDuration.cardPickUp),
                .scale(to: 1.0, duration: AnimationDuration.cardPickUp)
            ]
            gesture.card.run(.group(group))

            // clear the tracked gesture data
            panGestureRecognizerData[gestureRecognizer] = nil
        default:
            break
        }
    }

    /// process the pan gesture if casting
    func processPanGestureRecognizerFiredWhileCasting(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))

        switch gestureRecognizer.state {
        case .began:
            // generate the in order targets the user must drag over to cast

            // first is the start card
            castTargets = [CastPathTarget(card: startCard,
                                          overlay: createTargetOverlay(for: startCard.frame),
                                          frame: startCard.frame,
                                          isFinalCardPoint: true)]

            // then the cards in order of their position in the cast
            let sortedCards = cards.sorted(by: { (lhs, rhs) -> Bool in
                return model.castModel.index(of: lhs.model) ?? Int.max < model.castModel.index(of: rhs.model) ?? Int.max
            }).filter({ model.castModel.index(of: $0.model) != nil })

            for card in sortedCards {
                switch card.model.values {
                case .one(_):
                    // if the card has one unit, then the whole card is the target (not used yet)
                    let target = CastPathTarget(card: card,
                                                overlay: createTargetOverlay(for: card.frame),
                                                frame: card.frame,
                                                isFinalCardPoint: true)
                    castTargets.append(target)
                case .two(_, _):
                    // if the card has two units, then has two seperate targets, the bottom and top, in that order, that the user must drag over

                    // the bottom frame of the target
                    let bottomFrame = CGRect(x: card.position.x - card.size.width / 2,
                                             y: card.position.y - card.size.height / 2,
                                             width: card.size.width,
                                             height: card.size.height / 2)

                    // the visual indicator shown when the user drags over this target
                    let bottomOverlay = createTargetOverlay(for: bottomFrame)

                    // the target object
                    let bottomTarget = CastPathTarget(card: card,
                                                      overlay: bottomOverlay,
                                                      frame: bottomFrame,
                                                      isFinalCardPoint: false)

                    // same, except for top
                    let topFrame = CGRect(x: card.position.x - card.size.width / 2,
                                          y: card.position.y,
                                          width: card.size.width,
                                          height: card.size.height / 2)
                    let topOverlay = createTargetOverlay(for: topFrame)

                    // if the user drags of the top, then isFinalCardPoint is true as this is the final target for this card (and used to know when to tell model to perform a cast)
                    let topTarget = CastPathTarget(card: card,
                                                   overlay: topOverlay,
                                                   frame: topFrame,
                                                   isFinalCardPoint: true)

                    castTargets.append(contentsOf: [bottomTarget, topTarget])
                }
            }
        case .changed:
            // if gesture is in the frame of the first target...
            if let target = castTargets.first, target.frame.contains(adjustedLocation) {
                // get the index of this card in the model
                guard let index = model.castModel.index(of: target.card.model) else {
                    // if there is no index, then this is the start card (not tracked by the cast model)
                    if target.card == startCard {
                        // set the overlay to green and show it
                        //                        target.overlay.fillColor = .green
                        //                        target.overlay.isHidden = false

                        lastHolder = startCardHolder
                        currentHolder = startCardHolder
                        isInFalsePathMode = false


                        // remove this target
                        castTargets.removeFirst()
                        // manually trigger an interface update to this result
                        modelUpdated(update: .castResult(model.castModel.startMeasurement))

                        lastCorrectlyCastUnit = model.castModel.startMeasurement.unit
                    }
                    return
                }

                // only check this target if the card is the next to be casted
                guard model.castModel.isCardNextInChain(at: index) else { return }

                let holder = cardHolderTray.holders[index]
                currentHolder = holder

                if target.isFinalCardPoint {
                    // this target is the final target needed to complete the card

                    // tell the model this card's cast has been completed
                    model.castModel.cast(at: index)

                    if target.card.model.castState == .incorrectlyCast {
                        // run the bad animation
                        target.card.run(wiggleAction)
                        gestureRecognizer.isEnabled = false
                        __gestureRecognizerEnded()
                        gestureRecognizer.isEnabled = true
                    } else {
                        lastHolder = currentHolder
                    }

                } else if let castResult = model.castModel.potentialCastResult(at: index) {
                    // not the final target for this card, but get what the cast result of the full card will be

                    if castResult == .incorrectlyCast {
                        if case .two(let top, let bottom) = target.card.model.values, let lastCorrectlyCastUnit = lastCorrectlyCastUnit {
                            target.card.run(wiggleAction)
                             gestureRecognizer.isEnabled = false
                            __gestureRecognizerEnded()
                            gestureRecognizer.isEnabled = true
                        } else {
                            fatalError()
                        }
                    } else {
                        if case .two(let top, _) = target.card.model.values {
                            lastCorrectlyCastUnit = top.unit
                        } else {
                            fatalError()
                        }
                    }
                }

                // remove this target from the tracked list
                castTargets.removeFirst()
            } else if castTargets.count > 1 {
                let target = castTargets[1]
                if target.frame.contains(adjustedLocation) {
                    overlayNode.run(.fadeIn(withDuration: 0.5))
                    target.card.run(wiggleAction)
                    gestureRecognizer.isEnabled = false
                    isInFalsePathMode = true
                    __gestureRecognizerEnded()
                    gestureRecognizer.isEnabled = true
                } else {
                    update(goalText: "Goal: " + model.endUnit.displayString, animated: false)
                }
            }
        case .ended:
            __gestureRecognizerEnded()
        default:
            break
        }
    }

    private func __gestureRecognizerEnded() {
        if model.checkForCompletion() {
            Logging.shared.log(event: .spellsZagged, description: "correct cast")
            func addEmitter(position: CGPoint) {
                guard let emitter = SKEmitterNode(fileNamed: "MyParticle.sks") else {
                    fatalError()
                }
                emitter.position = position
                emitter.zPosition = 10000
                addChild(emitter)
            }
            let fade = SKAction.sequence([.wait(forDuration: 0.5), .fadeOut(withDuration: 1.0)])
            for card in cards where model.castModel.cards.contains(card.model) {
                addEmitter(position: card.position)
                card.run(fade)
            }
            addEmitter(position: startCard.position)
            startCard.run(fade)
            isUserInteractionEnabled = false

            self.run(SKAction.sequence([.wait(forDuration: 2.0), .fadeOut(withDuration: 1.0)]))
        } else {
            let currentPointMyBrainHurts = convert(currentHolder.position, from: currentHolder.parent!)
            let everythingIsTerrible = convert(lastHolder.position, from: lastHolder.parent!)

            let midpoint = CGPoint(x: (currentPointMyBrainHurts.x + everythingIsTerrible.x) / 2 - feedbackBackgroundSprite.frame.width / 2, y: (currentPointMyBrainHurts.y + everythingIsTerrible.y) / 2 - feedbackBackgroundSprite.frame.height / 2)


            feedbackBackgroundSprite.zPosition = overlayNode.zPosition + 1

            if !isInFalsePathMode {
                Logging.shared.log(event: .spellsZagged, description: "incorrect Cast")
                // remove all the overlays
                castOverlayNode.removeAllChildren()

                let matchColor = SKColor.blue.withAlphaComponent(0.2)
                if startCardHolder == lastHolder {
                    startCardHolder.fullFillShape?.fillColor = matchColor
                    startCardHolder.fullFillShape?.alpha = 1.0
                } else {
                    lastHolder.upperFillShape?.alpha = 1.0
                    lastHolder.upperFillShape?.fillColor = matchColor
                }
                feedbackBackgroundSprite.fillColor = .blue

                // hits this case if the case failed, but got to final unit
                if lastHolder == currentHolder {
                    castGoalLabelBackgroundNode.alpha = 1.0
                    castGoalLabelBackgroundNode.fillColor = matchColor
                    // this is bad and deserves a better solution, but I don't have time right now.

                } else {
                    currentHolder.lowerFillShape?.alpha = 1.0
                    currentHolder.lowerFillShape?.fillColor = matchColor
                }
                feedbackLabel.text = "MATCH"
                feedbackBackgroundSprite.alpha = 1
                feedbackBackgroundSprite.position = midpoint
            } else {
                feedbackLabel.text = "TRACE"
                feedbackBackgroundSprite.fillColor = .red
                feedbackBackgroundSprite.alpha = 1
                feedbackBackgroundSprite.position = CGPoint(x: startCard.position.x - feedbackBackgroundSprite.frame.width / 2, y: startCard.position.y + feedbackBackgroundSprite.frame.height / 2)
            }

            //exit cast
            isCasting.toggle()
            // clear the cast states
            model.castModel.resetCardCastStates()
        }
    }

    // create the overlay square that indicates when the user dragged over a unit
    private func createTargetOverlay(for rect: CGRect) -> SKShapeNode {
        let targetOverlay = SKShapeNode(rect: rect)
        targetOverlay.alpha = 0.1
        targetOverlay.isHidden = true
        targetOverlay.zPosition = newMaxZPosition()
        castOverlayNode.addChild(targetOverlay)
        return targetOverlay
    }

    private func _cleanFills() {
        castGoalLabel.text = "Goal: " + model.endUnit.displayString
        let fade = SKAction.fadeOut(withDuration: AnimationDuration.holderFillViewsFade / 4)
        if lastHolder == startCardHolder {
            lastHolder.fullFillShape?.run(fade)
        } else {
            lastHolder.upperFillShape?.run(fade)
        }
        currentHolder.lowerFillShape?.run(fade)
        castGoalLabelBackgroundNode.run(fade)
        overlayNode.run(fade)
        feedbackBackgroundSprite.run(fade)
    }

    private func update(goalText text: String, animated: Bool) {
        guard text != castGoalLabel.text else { return }
        if animated {
            let textSeq = SKAction.sequence([
                .fadeOut(withDuration: AnimationDuration.holderFillViewsFade / 4),
                .run {
                    self.castGoalLabel.text = text
                },
                .wait(forDuration: AnimationDuration.holderFillViewsFade / 4),
                .fadeIn(withDuration: AnimationDuration.holderFillViewsFade / 2)
            ])
            castGoalLabel.run(textSeq)
        } else {
            castGoalLabel.text = text
        }
    }
}
