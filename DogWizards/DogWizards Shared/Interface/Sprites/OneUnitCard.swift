//
//  OneUnitCard.swift
//  DogWizards
//
//  Created by Andrew Finke on 5/15/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A card sprite that supports showing one unit
class OneUnitCard: Card {

    // MARK: - Properties

    /// the unit label
    private let label = SKLabelNode()

    // MARK: - Configuration

    override func setupInterface() {
        label.fontSize = Design.cardSingleUnitFontSize
        label.fontName = Design.cardSingleUnitFontName
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)

        updateLabels()
    }

    override func updateLabels() {
        // make sure the model is one that only has one value
        guard case let CardModel.CardValues.one(value) = model.values else {
            fatalError("One unit card only supports one value")
        }

        if value.quantity == 1 {
            label.text = value.unit.displayString
        } else {
            label.text = value.displayString
        }
    }

}
