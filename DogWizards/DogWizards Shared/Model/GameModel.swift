//
//  GameModel.swift
//  DogWizards
//
//  Created by Garrett.Hedman on 4/28/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

/// Core model of the game
class GameModel {

    // MARK: - Types
    
    enum GameState {
        case level(LevelModel)
        case tutorial(TutorialModel)
        case pickCard(PickCardModel)
    }

    // MARK: - Properties
    
    var state: GameState
    /// Closure for informing listener (usually a game view) of an update
    var didChangeState: ((_ state: GameState) -> Void)?

    // MARK: - Initialization
    
    init() {
        func randomUnit() -> Unit {
            return Unit.allCases.randomElement()!
        }
        
        let model = LevelModel(startUnits: [.dolphin, .pizza, .rock], castSize: 8, deck: [
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
            CardModel(units: .two(top: randomUnit(), bottom: randomUnit()))
            ])
        
        state = GameState.level(model)
    }
    
}
