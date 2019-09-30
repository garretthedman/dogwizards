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
    /// The end unit a user is building toward
    let endUnit: Unit
    /// All the cards the user has
    let deck: [CardModel]
    /// Model for tracking cast state
    let castModel: CastModel

    enum Update {
        case completed(start: Unit, end: Unit)
    }
    
    /// Closure for informing listener (usually a sprite) of an update
    var didUpdate: ((Update) -> Void)?
    
    // MARK: - Initialization
    
    init(startUnits: [Unit], endUnit: Unit, castSize: Int, deck: [CardModel]) {
        // make sure we have at least one start unit and set that as the current
        guard let startUnit = startUnits.first else { fatalError() }
        self.startUnits = startUnits
        self.castModel = CastModel(startUnit: startUnit, endUnit: endUnit, size: castSize)
        self.endUnit = endUnit
        self.deck = deck
    }
    
    func checkForCompletion() -> Bool {
        if castModel.isCastSuccessful() {
            // castModel.resetCardCastStates()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.didUpdate?(.completed(start: self.castModel.startUnit,
                                           end: self.castModel.endUnit))
            }
            return true
        } else {
            return false
        }
    }
}
