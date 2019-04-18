//
//  GameViewController.swift
//  DogWizards iOS
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Properties

    var scene: GameScene?
    var skView: SKView {
        guard let view = view as? SKView else { fatalError() }
        return view
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.scene = scene
        skView.presentScene(scene)

        configureGestureRecognizers()
    }

    override func loadView() {
        let skView = SKView()
        skView.showsFPS = true
        skView.showsNodeCount = true
        view = skView
    }

    // MARK: - Gesture Recognizers

    func configureGestureRecognizers() {
        let panGestureRecorgnizer = GameScenePanGestureRecorgnizer(target: self,
                                                                   action: #selector(panGestureRecognizerFired(_:)))
        skView.addGestureRecognizer(panGestureRecorgnizer)

        let tapGestureRecorgnizer = GameSceneTapGestureRecorgnizer(target: self,
                                                                   action: #selector(tapGestureRecognizerFired(_:)))
        tapGestureRecorgnizer.numberOfTapsRequired = 1
        tapGestureRecorgnizer.numberOfTouchesRequired = 1
        skView.addGestureRecognizer(tapGestureRecorgnizer)
    }

    @objc func tapGestureRecognizerFired(_ gestureRecognizer: GameSceneTapGestureRecorgnizer) {
        scene?.tapGestureRecognizerFired(gestureRecognizer)
    }

    @objc func panGestureRecognizerFired(_ gestureRecognizer: GameScenePanGestureRecorgnizer) {
        scene?.panGestureRecognizerFired(gestureRecognizer)
    }

}
