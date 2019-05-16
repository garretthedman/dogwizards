//
//  LevelScene.swift
//  DogWizards Shared
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {

    // MARK: - Sprites

    var maxZPosition = CGFloat(1)

    let startCard: OneUnitCard
    let castButton = Button(text: "CAST")
    let cardHolderTray: CardHolderTray

    let castResultLabel = SKLabelNode(text: "X")
    let castGoalLabel = SKLabelNode(text: "Goal: Pizza")

    var cards = [Card]()
    var startUnitButtons = [Button]()

    // MARK: - Gesture Tracking

    var panGestureRecognizerData = [GameViewPanGestureRecognizer: PanGestureRecognizerMetadata]()
    var castPanGestureRecognizerData: (card: Card, start: CGPoint)?

    // MARK: - Properties

    let model: LevelModel

    var isCasting = false {
        didSet {
            panGestureRecognizerData = [:]
            castButton.label.text = isCasting ? "X" : "CAST"

            let alpha: CGFloat = isCasting ? 0.25 : 1.0
            cards.forEach { card in
                if model.castModel.index(of: card.model) == nil {
                    card.run(.fadeAlpha(to: alpha, duration: 0.2))
                }
            }

            if !isCasting {
                model.castModel.resetCardCastStates()
            }
        }
    }

    var isShowingStartUnitOptions = false {
        didSet {
            print(isShowingStartUnitOptions)
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
        cardHolderTray = CardHolderTray(holderCount: model.castModel.cards.count)
        startCard = OneUnitCard(model: CardModel(units: .one(model.castModel.startUnit)))

        super.init(size: Design.sceneSize)
        scaleMode = .aspectFit
        backgroundColor = Design.backgroundColor
        anchorPoint = CGPoint(x: 0, y: 0)
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

    func configureCardHolderTray() {
        let xPosition = size.width / 2
            - cardHolderTray.size.width / 2
            + (Design.cardHolderSizeWidth + Design.cardHolderPaddingSize) / 2

        cardHolderTray.position = CGPoint(x: xPosition,
                                          y: size.height / 4 * 2.5)
        addChild(cardHolderTray)

        castResultLabel.text = "Pizza"
        castResultLabel.fontColor = .black
        castResultLabel.fontSize = 70
        castResultLabel.fontName = "AvenirNext-Medium"
        castResultLabel.position = CGPoint(x: size.width / 2,
                                          y: cardHolderTray.position.y + cardHolderTray.size.height + 100)
        addChild(castResultLabel)

        castGoalLabel.text = "Goal: Pizza"
        castGoalLabel.fontColor = .black
        castGoalLabel.fontSize = 40
        castGoalLabel.fontName = "AvenirNext-Medium"
        castGoalLabel.position = CGPoint(x: size.width / 2,
                                           y: cardHolderTray.position.y + cardHolderTray.size.height + 40)
        addChild(castGoalLabel)

        castButton.position = CGPoint(x: size.width / 2,
                                      y: cardHolderTray.position.y - Design.buttonHeight / 2 - 40)
        addChild(castButton)


        startCard.position = CGPoint(x: cardHolderTray.position.x - Design.cardSizeWidth / 2 - 10,
                                       y: cardHolderTray.position.y + (Design.cardHolderSizeWidth * Design.cardHolderSizeRatio) / 2)
        addChild(startCard)

        for unit in model.startUnits {
            let button = Button(text: unit.displayString)
            button.zPosition = -1
            button.alpha = 0.0
            button.position = CGPoint(x: startCard.position.x,
                                      y: startCard.position.y)
            addChild(button)
            startUnitButtons.append(button)
        }
    }

    func configureCards() {
        let cardSize = Design.cardSizeWidth + Design.cardPaddingSize
        let width = cardSize * CGFloat(model.deck.count - 1)
        let xOffset = size.width / 2 - width / 2
        for (index, cardModel) in model.deck.enumerated() {
            let card = TwoUnitCard(model: cardModel)
            let position = CGPoint(x: xOffset + cardSize * CGFloat(index), y: 200)
            card.position = position
            card.zPosition = maxZPosition
            maxZPosition += 0.01
            addChild(card)
            cards.append(card)
        }
    }

    // MARK: - Start Unit Selection

    func showStartUnitOptions() {
        for (index, button) in startUnitButtons.enumerated() {
            let position =  CGPoint(x: startCard.position.x,
                                    y: startCard.position.y - startCard.size.height - (10 + Design.buttonHeight) * CGFloat(index))
            button.run(.group([
                .fadeAlpha(to: 1.0, duration: 0.25),
                .move(to: position, duration: 0.25)])
            )
        }
    }

    func hideStartUnitOptions() {
        for button in startUnitButtons {
            let position =  CGPoint(x: startCard.position.x,
                                    y: startCard.position.y)
            button.run(.group([
                .fadeAlpha(to: 0.0, duration: 0.25),
                .move(to: position, duration: 0.25)])
            )
        }
    }

    // MARK: - Model

    func modelUpdated(update: CastModel.Update) {
        switch update {
        case .shift:
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
            let resultAction = SKAction.sequence([
                .scale(to: 1.2, duration: 0.1),
                .scale(to: 1.0, duration: 0.1),
                ])
            castResultLabel.text = result?.displayString ?? "?"

            if isCasting {
                castResultLabel.run(resultAction)
            }
        }
    }

    // MARK: - Gesture Recognizers

    func card(at point: CGPoint, inset: CGFloat = 0.0) -> Card? {
        guard let card = cards.sorted(by: { lhs, rhs -> Bool in
            return lhs.zPosition > rhs.zPosition
        }).first(where: { card -> Bool in
            return card.frame.insetBy(dx: inset, dy: inset).contains(point)
        }) else { return nil }
        return card
    }

    func tapGestureRecognizerFired(_ gestureRecognizer: GameViewTapGestureRecognizer) {
        guard let view = self.view else { return }

        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))

        if let card = card(at: adjustedLocation) as? TwoUnitCard, !isCasting {
            let inset = -Design.cardFlipButtonCushion
            let frame = card.flipButton.frame.insetBy(dx: inset, dy: inset)
            if frame.contains(convert(adjustedLocation, to: card)) {
                card.model.flip()
                return
            }
        } else if castButton.frame.contains(adjustedLocation) {
            model.castModel.prepareForCast()
            isCasting.toggle()
            return
        } else if startCard.frame.contains(adjustedLocation), !isCasting {
            isShowingStartUnitOptions.toggle()
            return
        } else if !isCasting {
            for (index, button) in startUnitButtons.enumerated() {
                if button.frame.contains(adjustedLocation) {
                    let startUnit = model.startUnits[index]
                    model.castModel.startUnit = startUnit
                    startCard.model.units = .one(startUnit)
                    startCard.updateLabels()
                    isShowingStartUnitOptions = false
                    break
                }
            }
        }
    }

    func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        guard let view = self.view else { return }

        if isCasting {
            processPanGestureRecognizerFiredWhileCasting(gestureRecognizer)
            return
        }

        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))
        if gestureRecognizer.state == .began {
            guard let card = card(at: adjustedLocation) as? TwoUnitCard else {
                panGestureRecognizerData[gestureRecognizer] = nil
                return
            }
            let data = PanGestureRecognizerMetadata(card: card, lastLocation: adjustedLocation)
            panGestureRecognizerData[gestureRecognizer] = data
        }

        guard let gesture = panGestureRecognizerData[gestureRecognizer] else { return }

        let diff = adjustedLocation - gesture.lastLocation
        gesture.card.position = gesture.card.position + diff
        panGestureRecognizerData[gestureRecognizer]?.lastLocation = adjustedLocation

        let trayPoint = convert(gesture.card.position, to: cardHolderTray)
        switch gestureRecognizer.state {
        case .began:
            if cardHolderTray.holders.first(where: { $0.frame.contains(trayPoint) }) != nil {
                model.castModel.pickUp(card: gesture.card)
            }
            gesture.card.zPosition = maxZPosition
            maxZPosition += 0.01

            let group: [SKAction] = [
                .fadeAlpha(to: Design.cardPickUpAlpha, duration: AnimationDuration.cardPickUp),
                .scale(to: Design.cardPickUpScale, duration: AnimationDuration.cardPickUp)
            ]

            gesture.card.run(.group(group))
        case .changed:
            for (index, cardHolder) in cardHolderTray.holders.enumerated() where cardHolder.frame.contains(trayPoint) {
                let holderPoint = convert(cardHolder.position, from: cardHolderTray)
                let cardDiff = gesture.card.position.x - holderPoint.x
                let direction: Direction = cardDiff > 0 ? .left : .right

                model.castModel.prepareForDrop(at: index, from: direction)
                break
            }
        case .ended:
            for (index, cardHolder) in cardHolderTray.holders.enumerated() where cardHolder.frame.contains(trayPoint) {
                let holderPoint = convert(cardHolder.position, from: cardHolderTray)

                if model.castModel.drop(card: gesture.card.model, at: index) {
                    let action = SKAction.move(to: holderPoint,
                                               duration: AnimationDuration.cardMoveToHolder)
                    gesture.card.run(action)
                }
                break
            }

            let group: [SKAction] = [
                .fadeAlpha(to: 1.0, duration: AnimationDuration.cardPickUp),
                .scale(to: 1.0, duration: AnimationDuration.cardPickUp)
            ]
            gesture.card.run(.group(group))

            panGestureRecognizerData[gestureRecognizer] = nil
        default:
            break
        }
    }

    func processPanGestureRecognizerFiredWhileCasting(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))

        switch gestureRecognizer.state {
        case .began:
            guard let card = card(at: adjustedLocation, inset: -Design.cardHolderPaddingSize) as? TwoUnitCard,
                let index = model.castModel.index(of: card.model) else {
                    return
            }

            castPanGestureRecognizerData = (card, adjustedLocation)
        case .ended:
            defer { castPanGestureRecognizerData = nil }

            guard let data = castPanGestureRecognizerData,
                let index = model.castModel.index(of: data.card.model) else {
                    return
            }

            let minX = data.card.position.x - Design.cardSizeWidth
            let maxX = data.card.position.x + data.card.size.width + Design.cardSizeWidth

            guard data.start.y < adjustedLocation.y,
                adjustedLocation.x > minX,
                adjustedLocation.x < maxX else {
                    return
            }

            let wiggleAction = SKAction.sequence([
                .repeat(.sequence([
                    .rotate(toAngle: CGFloat.pi / 16, duration: 0.1),
                    .rotate(toAngle: -CGFloat.pi / 16, duration: 0.1)]), count: 2),
                .rotate(toAngle: 0.0, duration: 0.1)
                ])

            if model.castModel.isCardNextInChain(at: index) {
                model.castModel.cast(at: index)
                if data.card.model.castState == .incorrectlyCast {
                    data.card.run(wiggleAction)
                } else {
                    data.card.run(.sequence([
                        .scale(to: 1.1, duration: 0.1),
                        .scale(to: 1.0, duration: 0.1)
                        ]))
                }
            } else if index != 0 {
                let nonCorrectCast = model.castModel.firstNonCorrectCast()
                let previousCard = cards.first(where: { $0.model == nonCorrectCast })
                previousCard?.run(wiggleAction)
            }
        default:
            break
        }
    }
}
