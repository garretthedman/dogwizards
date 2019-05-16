//
//  OneUnitCard.swift
//  DogWizards
//
//  Created by Andrew Finke on 5/15/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class OneUnitCard: Card {

    // MARK: - Properties

    private let label = SKLabelNode()

    // MARK: - Configuration

    override func setupInterface() {
        let fontSize = Design.cardSingleUnitFontSize
        label.fontSize = fontSize
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)

        updateLabels()
    }

    override func updateLabels() {
        guard case let CardModel.CardUnits.one(unit) = model.units else {
            fatalError("One unit card only supports one unit")
        }

        label.text = unit.displayString
    }

}
