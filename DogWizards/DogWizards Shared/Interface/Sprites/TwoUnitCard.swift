//
//  TwoUnitCard.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class TwoUnitCard: Card {

    // MARK: - Properties

    private let topLabel = SKLabelNode()
    private let bottomLabel = SKLabelNode()
    let flipButton = SKSpriteNode()

    // MARK: - Configuration

    override func setupInterface() {
        let fontSize = Design.cardFontSize
        let offset = size.height / 4
        topLabel.fontSize = fontSize
        topLabel.horizontalAlignmentMode = .center
        topLabel.verticalAlignmentMode = .center
        topLabel.position = CGPoint(x: 0, y: offset)
        addChild(topLabel)

        bottomLabel.fontSize = fontSize
        bottomLabel.horizontalAlignmentMode = .center
        bottomLabel.verticalAlignmentMode = .center
        bottomLabel.position = CGPoint(x: 0, y: -offset)
        addChild(bottomLabel)

        flipButton.texture = SKTexture(imageNamed: "Flip - Sketch")
        flipButton.size = CGSize(width: 22, height: 22)
        flipButton.position = .zero
        addChild(flipButton)

        model.didFlip = didFlip
        updateLabels()
    }

    func updateLabels() {
        topLabel.text = model.topUnit.displayString
        bottomLabel.text = model.bottomUnit.displayString
    }

    // MARK: - Helpers

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
