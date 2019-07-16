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

    /// The cast button
    private let castButton = Button(text: "Perform!")

    /// The tray that holds the user's cards to cast. Each slot in the tray has a visual affordance indicating a card can be dropped.
    private let cardHolderTray: CardHolderTray

    /// Top label indicating current cast result
    private let castResultLabel = SKLabelNode(text: "X")
    /// Goal label
    private let castGoalLabel = SKLabelNode(text: "")
    /// Node which contains all the overlays from the cast targets
    private let castOverlayNode = SKNode()

    /// All the card sprites on screen
    private var cards = [Card]()
    /// All the start unit buttons that are shown when the user wants to change the start card
    private var startUnitButtons = [Button]()

    /// All the background images for the game
    let streetBackground = SKSpriteNode()
    
    // MARK: - Gesture Tracking

    /// Used to track the cards the user is panning accross the screen
    private var panGestureRecognizerData = [GameViewPanGestureRecognizer: PanGestureRecognizerMetadata]()
    /// An array (w/ a specific order) of the targets the user should hit when casting
    private var castTargets = [CastPathTarget]()

    // MARK: - Properties

    /// The model to represent
    private let model: LevelModel

    /// Bool indicating if in casting more
    private var isCasting = false {
        didSet {
            // Cancel all active gestures
            panGestureRecognizerData = [:]
            // Update the button label
            if (isCasting){
                castButton.label.text = "Perform!"
                castButton.label.fontColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            }else{
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

    // MARK: - Initialization

    init(for model: LevelModel) {
        self.model = model

        // create a tray that can hold the max amount of cards supported in this level's cast
        cardHolderTray = CardHolderTray(holderCount: model.castModel.cards.count)
        // create the far left card indicating the start unit
        startCard = OneUnitCard(model: CardModel(units: .one(model.castModel.startUnit)))

        super.init(size: Design.sceneSize)
        scaleMode = .aspectFit
        backgroundColor = Design.backgroundColor
        anchorPoint = CGPoint(x: 0, y: 0)
        
        // add images for the background
        streetBackground.texture = SKTexture(imageNamed: "rockBack")
        streetBackground.position = CGPoint(x: Design.sceneSize.width/2, y: Design.sceneSize.height/1.2)
        streetBackground.size = CGSize(width: 560, height: 249)
        addChild(streetBackground)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Scene Configuration

    override func didMove(to view: SKView) {
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
        startCard.position = CGPoint(x: cardHolderTray.position.x - Design.cardSizeWidth / 2 - 10,
                                       y: cardHolderTray.position.y + (Design.cardHolderSizeWidth * Design.cardHolderSizeRatio) / 2)
        addChild(startCard)

        // create buttons for possible start units (hidden to start)
        for unit in model.startUnits {
            
            if (unit != .start){
                let button = Button(text: unit.displayString)
                button.zPosition = -1
                button.alpha = 0.0
                button.position = CGPoint(x: startCard.position.x,
                                          y: startCard.position.y)
                addChild(button)
                startUnitButtons.append(button)
            }else {
                print("Had start!")
                print(unit.displayString)
            }
        }
        addChild(castOverlayNode)
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

            let text = result?.displayStringImage ?? "?"
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
            
        } else if castButton.frame.contains(adjustedLocation) {
            // The tap was on the cast button

            // inform the cast model to shift the cards
            model.castModel.prepareForCast()

            // toggle the casting mode state
            isCasting.toggle()

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

                    // get the unit at that index
                    let startUnit = model.startUnits[index+1]
                    // update the cast model
                    model.castModel.startUnit = startUnit
                    // update the card model
                    startCard.model.units = .one(startUnit)
                    // update the goal image
                    modelUpdated(update: .castResult(model.castModel.startUnit))
                    // trigger a ui update
                    startCard.updateLabels()
                    // hide the start unit option buttons
                    isShowingStartUnitOptions = false
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
                switch card.model.units {
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
                        target.overlay.fillColor = .green
                        target.overlay.isHidden = false
                        // remove this target
                        castTargets.removeFirst()
                        // manually trigger an interface update to this result
                        modelUpdated(update: .castResult(model.castModel.startUnit))
                    }
                    return
                }

                // only check this target if the card is the next to be casted
                guard model.castModel.isCardNextInChain(at: index) else { return }

                if target.isFinalCardPoint {
                    // this target is the final target needed to complete the card

                    // tell the model this card's cast has been completed
                    model.castModel.cast(at: index)

                    if target.card.model.castState == .incorrectlyCast {
                        // if this was a bad cast, show a red overlay
                        target.overlay.fillColor = .red
                        target.overlay.isHidden = false

                        // run the bad animation
                        let wiggleAction = SKAction.sequence([
                            .repeat(.sequence([
                                .rotate(toAngle: CGFloat.pi / 16, duration: 0.1),
                                .rotate(toAngle: -CGFloat.pi / 16, duration: 0.1)]), count: 2),
                            .rotate(toAngle: 0.0, duration: 0.1)
                            ])
                        target.card.run(wiggleAction)
                    } else {
                        // correct cast, show green and pulse animation
                        target.overlay.fillColor = .green
                        target.overlay.isHidden = false
                        target.card.run(.sequence([
                            .scale(to: 1.1, duration: 0.1),
                            .scale(to: 1.0, duration: 0.1)
                            ]))
                    }
                } else if let castResult = model.castModel.potentialCastResult(at: index) {
                    // not the final target for this card, but get what the cast result of the full card will be

                    if castResult == .incorrectlyCast {
                        // if this will be a bad cast, show red
                        target.overlay.fillColor = .red
                        target.overlay.isHidden = false
                    } else {
                        target.overlay.fillColor = .green
                        target.overlay.isHidden = false
                    }
                }

                // remove this target from the tracked list
                castTargets.removeFirst()
            }
        case .ended:
            model.checkForCompletion()
            // remove all the overlays
            castOverlayNode.removeAllChildren()
            //exit cast
            isCasting.toggle()
            // clear the cast states
            model.castModel.resetCardCastStates()
        default:
            break
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
}
