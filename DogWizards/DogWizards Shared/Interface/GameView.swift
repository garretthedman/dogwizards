//
//  GameView.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/18/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// Core interface component of the game. Hosts the scenes (a level, tutorial, etc.)
class GameView: SKView {

    // MARK: - Properties

    /// The game model
    let model = GameModel()

    // MARK: - Initialization

    /// Configures the game view. Should be called by the view controller the hosts the game view
    func start() {
        configureGestureRecognizers()

        // listen to changes in model state
        model.didChangeState = modelTransitioned(to:)

        // prepare to show the state the model is currently in
        modelTransitioned(to: model.state)
    }

    // MARK: - Model

    /// Updates the presented scene to match the state of the game modal
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

        // present the new scene on this view
        presentScene(scene)
    }

    // MARK: - Gesture Recognizers

    /// one time configuration of the gesture recognizers for the view. Since they live in the view, not a specific scene, only need to call on the inital setup of the view.
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
        if let scene = self.scene as? LevelScene {
            scene.tapGestureRecognizerFired(gestureRecognizer)
        }
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameViewPanGestureRecognizer) {
        if let scene = self.scene as? LevelScene {
            scene.panGestureRecognizerFired(gestureRecognizer)
        }
    }
}
