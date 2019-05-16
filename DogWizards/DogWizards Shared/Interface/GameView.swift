//
//  GameView.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/18/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class GameView: SKView {

    // MARK: - Properties

    let model = GameModel()

    // MARK: - Initialization

    func start() {
        configureGestureRecognizers()
        model.didChangeState = modelTransitioned(to:)
        modelTransitioned(to: model.state)
    }

    // MARK: - Model

    func modelTransitioned(to state: GameModel.GameState) {
        let scene: SKScene
        switch state {
        case .level(let levelModel):
            scene = LevelScene(for: levelModel)
        case .tutorial(_):
            scene = SKScene()
        case .pickCard(_):
            scene = SKScene()
        }
        presentScene(scene)
    }

    // MARK: - Gesture Recognizers

    func configureGestureRecognizers() {
        let panGestureRecognizer = GameViewPanGestureRecognizer(target: self,
                                                                   action: #selector(panGestureRecognizerFired(_:)))
        addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = GameViewTapGestureRecognizer(target: self,
                                                                   action: #selector(tapGestureRecognizerFired(_:)))

        #if os(iOS)
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        #endif
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func tapGestureRecognizerFired(_ gestureRecognizer: GameViewTapGestureRecognizer) {
        guard let scene = self.scene as? LevelScene else { return }
        scene.tapGestureRecognizerFired(gestureRecognizer)
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        guard let scene = self.scene as? LevelScene else { return }
        scene.panGestureRecognizerFired(gestureRecognizer)
    }

}
