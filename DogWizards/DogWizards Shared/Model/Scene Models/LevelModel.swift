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

    /// The possible values a user has to choose from
    let startValues: [CardValue]
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
    
    init(startValues: [CardValue], endUnit: Unit, castSize: Int, deck: [CardModel]) {
        // make sure we have at least one start unit and set that as the current
        guard let startValue = startValues.first else { fatalError() }
        self.startValues = startValues
        self.castModel = CastModel(startValue: startValue, endUnit: endUnit, size: castSize)
        self.endUnit = endUnit
        self.deck = deck
    }
    
    func checkForCompletion() -> Bool {
        if castModel.isCastSuccessful() {
            // castModel.resetCardCastStates()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.didUpdate?(.completed(start: self.castModel.startValue.unit,
                                           end: self.castModel.endUnit))
            }
            return true
        } else {
            return false
        }
    }
}
