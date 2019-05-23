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
    
    var state: GameState {
        didSet {
            didChangeState?(state)
        }
    }
    /// Closure for informing listener (usually a game view) of an update
    var didChangeState: ((_ state: GameState) -> Void)?
    
    var levelNumber = 1

    // MARK: - Initialization
    
    init() {
       
        //Code for random units
        /*func randomUnit() -> Unit {
            return Unit.allCases.randomElement()!
        }
        
         CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
         */
        
        let model = LevelModel(startUnits: [.dolphin], endUnit: .rock, castSize: 1, deck: [
            CardModel(units: .two(top: .dolphin, bottom: .rock))])
        
        state = GameState.level(model)
        
        model.didUpdate = levelUpdated(update:)
        
    }
    
    func levelUpdated(update: LevelModel.Update) {
        switch update {
        case .completed(let start, let end):
            
            if levelNumber == 1 {
                let nextLevel = LevelModel(startUnits: [.dolphin], endUnit: .rock, castSize: 2, deck: [
                    CardModel(units: .two(top: .dolphin, bottom: .rock)),
                    CardModel(units: .two(top: .rock, bottom: .rock))
                    ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber += 1
            }
            
            else if levelNumber == 2 {
                let nextLevel = LevelModel(startUnits: [.dolphin], endUnit: .rock, castSize: 3, deck: [
                    CardModel(units: .two(top: .dolphin, bottom: .mouse)),
                    CardModel(units: .two(top: .mouse, bottom: .pancake)),
                    CardModel(units: .two(top: .pancake, bottom: .rock))
                    ])
                state = GameState.level(nextLevel)
                levelNumber += 1
            }
            
            else if levelNumber == 3 {
                let nextLevel = LevelModel(startUnits: [.dolphin], endUnit: .rock, castSize: 4, deck: [
                    CardModel(units: .two(top: .dolphin, bottom: .mouse)),
                    CardModel(units: .two(top: .mouse, bottom: .pancake)),
                    CardModel(units: .two(top: .pizza, bottom: .pancake)),
                    CardModel(units: .two(top: .pizza, bottom: .rock))
                    ])
                state = GameState.level(nextLevel)
                levelNumber += 1
            }
            
            else if levelNumber == 4{
                let nextLevel = LevelModel(startUnits: [.pizza], endUnit: .rock, castSize: 5, deck: [
                    CardModel(units: .two(top: .mouse, bottom: .unicorn)),
                    CardModel(units: .two(top: .tooth, bottom: .rock)),
                    CardModel(units: .two(top: .rock, bottom: .pancake)),
                    CardModel(units: .two(top: .mouse, bottom: .pizza)),
                    CardModel(units: .two(top: .pizza, bottom: .mouse))
                    ])
            }
            
        }
    }
}
