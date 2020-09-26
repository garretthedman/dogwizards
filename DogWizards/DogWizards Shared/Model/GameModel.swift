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
            if case .level(let level) = state {
                Logging.shared.activeLevel = level
            }
        }
    }
    /// Closure for informing listener (usually a game view) of an update
    var didChangeState: ((_ state: GameState) -> Void)?
    
    var levelNumber = 0

    var levelStartDate = Date()

    // MARK: - Initialization
    
    init() {
       
        //Code for random units
        /*func randomUnit() -> Unit {
            return Unit.allCases.randomElement()!
        }
        
         CardModel(units: .two(top: randomUnit(), bottom: randomUnit())),
         */

        let model = LevelModel(startValues: [
            CardValue(unit: .start),
            CardValue(unit: .pancake),
            CardValue(unit: .rock)
        ], endUnit: .rock, castSize: 1, deck: [
            CardModel(values: .two(top: CardValue(unit: .rock), bottom: CardValue(unit: .pancake)))
        ])

        levelNumber += 1

        state = GameState.level(model)
        model.didUpdate = levelUpdated(update:)
        Logging.shared.activeLevel = model
    }
    
    func levelUpdated(update: LevelModel.Update) {
        switch update {
        case .completed(let start, let end):
            Logging.shared.log(event: .levelCompleted, description: "number: \(levelNumber), time: \(-levelStartDate.timeIntervalSinceNow)")
            levelStartDate = Date()

            if levelNumber == 1 {
                let nextLevel = LevelModel(startValues: [
                    CardValue(unit: .start),
                    CardValue(unit: .pancake),
                    CardValue(unit: .rock),
                    ], endUnit: .rock, castSize: 1, deck: [
                        CardModel(values: .two(top: CardValue(unit: .pancake), bottom: CardValue(unit: .rock))),
                ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber += 1
            }

            else if levelNumber == 2 {
                let nextLevel = LevelModel(startValues: [
                    CardValue(unit: .start),
                    CardValue(unit: .mouse),
                    CardValue(unit: .dolphin),
                    CardValue(unit: .rock)
                    ], endUnit: .rock, castSize: 2, deck: [
                        CardModel(values: .two(top: CardValue(unit: .dolphin), bottom: CardValue(unit: .mouse))),
                        CardModel(values: .two(top: CardValue(unit: .mouse), bottom: CardValue(unit: .rock)))
                ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber += 1
            }
            
        else if levelNumber == 3 {
            let nextLevel = LevelModel (startValues: [
                CardValue(unit: .start),
                CardValue(unit: .pancake),
                CardValue(unit: .unicorn),
                CardValue(unit: .pizza)],
                endUnit: .rock, castSize: 4, deck: [
                    CardModel(values: .two(top: CardValue(unit: .pancake), bottom: CardValue(unit: .rock))),
               CardModel(values: .two(top: CardValue(unit: .pancake), bottom: CardValue(unit: .unicorn))),
                CardModel(values: .two(top: CardValue(unit: .pizza), bottom: CardValue(unit: .unicorn))),
                CardModel(values: .two(top: CardValue(unit: .unicorn), bottom: CardValue(unit: .pizza)))
                ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber += 1
            }
            
            else if levelNumber == 4 {
                let nextLevel = LevelModel(startValues: [
                    CardValue(unit: .start),
                    CardValue(unit: .mouse),
                    CardValue(unit: .dolphin),
                    CardValue(unit: .pizza),
                    CardValue(unit: .unicorn),
                    CardValue(unit: .pancake),
                    CardValue(unit: .rock)
                    ], endUnit: .rock, castSize: 6, deck: [
                        CardModel(values: .two(top: CardValue(unit: .unicorn), bottom: CardValue(unit: .rock))),
                        CardModel(values: .two(top: CardValue(unit: .pizza), bottom: CardValue(unit: .mouse))),
                        CardModel(values: .two(top: CardValue(unit: .mouse), bottom: CardValue(unit: .unicorn))),
                        CardModel(values: .two(top: CardValue(unit: .dolphin), bottom: CardValue(unit: .mouse))),
                        CardModel(values: .two(top: CardValue(unit: .unicorn), bottom: CardValue(unit: .pizza))),
                        CardModel(values: .two(top: CardValue(unit: .unicorn), bottom: CardValue(unit: .mouse)))
                ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber += 1
            }
            
                
            else if levelNumber == 5 {
               // let model = LevelModel(startValues: [
                let nextLevel = LevelModel(startValues: [
                    CardValue(unit: .mm, quantity: 100),
                    CardValue(unit: .cm, quantity: 10),
                ], endUnit: .km, castSize: 3, deck: [
                        CardModel(values: .two(top: CardValue(unit: .mm, quantity: 10), bottom: CardValue(unit: .cm, quantity: 1))),
                        CardModel(values: .two(top: CardValue(unit: .cm, quantity: 100), bottom: CardValue(unit: .m, quantity: 1))),
                        CardModel(values: .two(top: CardValue(unit: .km, quantity: 1), bottom: CardValue(unit: .m, quantity: 1000)))
            ])
                state = GameState.level(nextLevel)
                nextLevel.didUpdate = levelUpdated(update:)
                levelNumber = 1
            }
        }
    }
}
