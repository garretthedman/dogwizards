//
//  GameViewController.swift
//  DogWizards macOS
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Cocoa
import SpriteKit

class GameViewController: NSViewController {

    // MARK: - Properties

    var scene: GameScene?
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        func randomUnit() -> Unit {
            return Unit.allCases.randomElement()!
        }

        let model = GameModel(startUnit: .dolphin, castSize: 5, deck: [
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit()),
            CardModel(topUnit: randomUnit(), bottomUnit: randomUnit())
            ])
        
        let scene = GameScene(for: model)
        self.scene = scene

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)

        skView.showsFPS = true
        skView.showsNodeCount = true

        configureGestureRecognizers()
    }

    // MARK: - Gesture Recognizers

    func configureGestureRecognizers() {
        let skView = self.view as! SKView
        let panGestureRecorgnizer = GameScenePanGestureRecorgnizer(target: self,
                                                                   action: #selector(panGestureRecognizerFired(_:)))
        skView.addGestureRecognizer(panGestureRecorgnizer)

        let tapGestureRecorgnizer = GameSceneTapGestureRecorgnizer(target: self,
                                                                   action: #selector(tapGestureRecognizerFired(_:)))
        skView.addGestureRecognizer(tapGestureRecorgnizer)
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameScenePanGestureRecorgnizer) {
        scene?.panGestureRecognizerFired(gestureRecognizer)
    }

    @objc func tapGestureRecognizerFired(_ gestureRecognizer: GameSceneTapGestureRecorgnizer) {
        scene?.tapGestureRecognizerFired(gestureRecognizer)
    }

}

