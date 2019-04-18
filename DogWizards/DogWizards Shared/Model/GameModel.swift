//
//  GameModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

class GameModel {

    // MARK: - Properties

    let startUnit: Unit
    let deck: [CardModel]
    let castModel: CastModel

    // MARK: - Initialization
    
    init(startUnit: Unit, castSize: Int, deck: [CardModel]) {
        self.startUnit = startUnit
        self.castModel = CastModel(size: castSize)
        self.deck = deck
    }
}
