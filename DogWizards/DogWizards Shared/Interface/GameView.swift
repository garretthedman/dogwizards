//
//  GameView.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/18/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class GameView: SKView {

    func start() {
        showsFPS = true
        showsNodeCount = true


        func randomUnit() -> Unit {
            return Unit.allCases.randomElement()!
        }

        let model = LevelModel(startUnit: .dolphin, castSize: 6, deck: [
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit())
            ])

        let scene = LevelScene(for: model)
        presentScene(scene)

        configureGestureRecognizers()
    }

    // MARK: - Gesture Recognizers

    func configureGestureRecognizers() {
        let panGestureRecorgnizer = GameViewPanGestureRecorgnizer(target: self,
                                                                   action: #selector(panGestureRecognizerFired(_:)))
        addGestureRecognizer(panGestureRecorgnizer)

        let tapGestureRecorgnizer = GameViewTapGestureRecorgnizer(target: self,
                                                                   action: #selector(tapGestureRecognizerFired(_:)))

        #if os(iOS)
        tapGestureRecorgnizer.numberOfTapsRequired = 1
        tapGestureRecorgnizer.numberOfTouchesRequired = 1
        #endif
        addGestureRecognizer(tapGestureRecorgnizer)
    }

    @objc func tapGestureRecognizerFired(_ gestureRecognizer: GameViewTapGestureRecorgnizer) {
        guard let scene = self.scene as? LevelScene else { return }
        scene.tapGestureRecognizerFired(gestureRecognizer)
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecorgnizer) {
        guard let scene = self.scene as? LevelScene else { return }
        scene.panGestureRecognizerFired(gestureRecognizer)
    }

}
