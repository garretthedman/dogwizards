//
//  GameModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

/// Model for tracking a level
class LevelModel {

    // MARK: - Properties

    /// The possible units a user has to choose from
    let startUnits: [Unit]
    /// All the cards the user has
    let deck: [CardModel]
    /// Model for tracking cast state
    let castModel: CastModel

    // MARK: - Initialization
    
    init(startUnits: [Unit], castSize: Int, deck: [CardModel]) {
        // make sure we have at least one start unit and set that as the current
        guard let startUnit = startUnits.first else { fatalError() }
        self.startUnits = startUnits
        self.castModel = CastModel(startUnit: startUnit, size: castSize)
        self.deck = deck
    }
}
