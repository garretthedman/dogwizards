//
//  GameModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

class LevelModel {

    // MARK: - Properties

    let startUnits: [Unit]
    let deck: [CardModel]
    let castModel: CastModel

    // MARK: - Initialization
    
    init(startUnits: [Unit], castSize: Int, deck: [CardModel]) {
        guard let startUnit = startUnits.first else { fatalError() }
        self.startUnits = startUnits
        self.castModel = CastModel(startUnit: startUnit, size: castSize)
        self.deck = deck
    }
}
