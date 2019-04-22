//
//  LevelScene.swift
//  DogWizards Shared
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {

    // MARK: - Properties

    let model: LevelModel
    var maxZPosition = CGFloat(1)

    var cards = [Card]()
    let cardHolderTray: CardHolderTray

    var panGestureRecognizerData = [GameViewPanGestureRecorgnizer: PanGestureRecognizerMetadata]()

    // MARK: - Initialization

    init(for model: LevelModel) {
        self.model = model
        cardHolderTray = CardHolderTray(holderCount: model.castModel.cards.count)

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

        model.castModel.didShift = modelUpdated
    }

    func configureCardHolderTray() {
        let xPosition = size.width / 2 - cardHolderTray.size.width / 2
        cardHolderTray.position = CGPoint(x: xPosition, y: size.height / 4 * 2.5)
        addChild(cardHolderTray)
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

    // MARK: - Model

    func modelUpdated() {
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
    }

    // MARK: - Gesture Recognizers

    func card(at point: CGPoint) -> Card? {
        guard let card = cards.sorted(by: { lhs, rhs -> Bool in
            return lhs.zPosition > rhs.zPosition
        }).first(where: { card -> Bool in
            return card.frame.contains(point)
        }) else { return nil }
        return card
    }

    func tapGestureRecognizerFired(_ gestureRecognizer: GameViewTapGestureRecorgnizer) {
        guard let view = self.view else { return }

        let adjustedLocation = convertPoint(fromView: gestureRecognizer.location(in: view))

        // temp for testing cast compact
        if adjustedLocation.x < 100 && adjustedLocation.y < 100 {
            model.castModel.prepareForCast()
            return
        }

        guard let card = card(at: adjustedLocation) as? TwoUnitCard else { return }

        let inset = -Design.cardFlipButtonCushion
        let frame = card.flipButton.frame.insetBy(dx: inset, dy: inset)
        if frame.contains(convert(adjustedLocation, to: card)) {
            card.model.flip()
        }
    }

    func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecorgnizer) {
        guard let view = self.view else { return }

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
}
