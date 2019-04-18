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

        let model = GameModel(startUnit: .dolphin, castSize: 6, deck: [
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit())
            ])

        let scene = GameScene(for: model)
        presentScene(scene)

        configureGestureRecognizers()
    }

    // MARK: - Gesture Recognizers

    func configureGestureRecognizers() {
        let panGestureRecorgnizer = GameScenePanGestureRecorgnizer(target: self,
                                                                   action: #selector(panGestureRecognizerFired(_:)))
        addGestureRecognizer(panGestureRecorgnizer)

        let tapGestureRecorgnizer = GameSceneTapGestureRecorgnizer(target: self,
                                                                   action: #selector(tapGestureRecognizerFired(_:)))

        #if os(iOS)
        tapGestureRecorgnizer.numberOfTapsRequired = 1
        tapGestureRecorgnizer.numberOfTouchesRequired = 1
        #endif
        addGestureRecognizer(tapGestureRecorgnizer)
    }

    @objc func tapGestureRecognizerFired(_ gestureRecognizer: GameSceneTapGestureRecorgnizer) {
        guard let scene = self.scene as? GameScene else { return }
        scene.tapGestureRecognizerFired(gestureRecognizer)
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameScenePanGestureRecorgnizer) {
        guard let scene = self.scene as? GameScene else { return }
        scene.panGestureRecognizerFired(gestureRecognizer)
    }

}
