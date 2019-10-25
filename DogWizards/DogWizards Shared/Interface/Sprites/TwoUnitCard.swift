//
//  TwoUnitCard.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A card sprite that supports showing two units
class TwoUnitCard: Card {

    // MARK: - Properties

    private let topLabel = SKLabelNode()
    private let bottomLabel = SKLabelNode()
    let flipButton = SKSpriteNode()

    // MARK: - Configuration

    override func setupInterface() {
        let offset = size.height / 4
        topLabel.fontSize = Design.cardTwoUnitFontSize
        topLabel.horizontalAlignmentMode = .center
        topLabel.verticalAlignmentMode = .center
        topLabel.position = CGPoint(x: 0, y: offset)
        topLabel.fontColor = .black
        topLabel.fontName = Design.cardTwoUnitFontName
        addChild(topLabel)

        bottomLabel.fontSize = Design.cardTwoUnitFontSize
        bottomLabel.horizontalAlignmentMode = .center
        bottomLabel.verticalAlignmentMode = .center
        bottomLabel.position = CGPoint(x: 0, y: -offset)
        bottomLabel.fontColor = .black
        bottomLabel.fontName = Design.cardTwoUnitFontName
        addChild(bottomLabel)

        flipButton.texture = SKTexture(imageNamed: "Flip - Sketch")
        flipButton.size = CGSize(width: 22, height: 22)
        flipButton.position = .zero
        addChild(flipButton)

        // listen to updates from the card model
        model.didUpdate = { update in
            switch update {
            case .cast(_):
                // the card was cast
                self.updateCastState()
            case .flipped:
                // the card was flipped
                self.didFlip()
            }
        }

        updateLabels()
        updateCastState()
    }

    override func updateLabels() {
        // make sure the model is one that has two values
        guard case let CardModel.CardValues.two(top, bottom) = model.values else {
            fatalError("Two unit card only supports two values")
        }

        if top.quantity == 1 && !Design.showSingleUnit {
            topLabel.text = top.unit.displayString
        } else {
            topLabel.text = top.displayString
        }

        if bottom.quantity == 1 && !Design.showSingleUnit {
            bottomLabel.text = bottom.unit.displayString
        } else {
            bottomLabel.text = bottom.displayString
        }
    }

    func updateCastState() {
        // updates the sprite's texture (image) based on cast state

        switch model.castState {
        case .uncasted:
            // a normal card
            self.texture = SKTexture(imageNamed: "Card - Two")
        case .incorrectlyCast:
            break
            // this card was incorrectly cast (unit didn't align with previous card)
//            self.texture = SKTexture(imageNamed: "Card - Two - Red")
        case .correctlyCast:
            break
            // this card was correctly cast
//            self.texture = SKTexture(imageNamed: "Card - Two - Green")
        }
    }

    // MARK: - Helpers

    /// run a neat animation when the model units were flipped
    private func didFlip() {
        let duration = AnimationDuration.cardFlip

        let swapLabelsAction = SKAction.run {
            self.updateLabels()
        }

        let mainActions = SKAction.sequence([
            SKAction.rotate(toAngle: -CGFloat.pi / 2, duration: duration / 2),
            SKAction.rotate(toAngle: CGFloat.pi / 2, duration: 0),
            swapLabelsAction,
            SKAction.rotate(toAngle: 0, duration: duration / 2)
            ])
        let labelActions = SKAction.sequence([
            SKAction.rotate(toAngle: CGFloat.pi / 2, duration: duration / 2),
            SKAction.rotate(toAngle: -CGFloat.pi / 2, duration: 0),
            SKAction.rotate(toAngle: 0, duration: duration / 2)
            ])

        topLabel.run(labelActions)
        bottomLabel.run(labelActions)
        run(mainActions)
    }

}
