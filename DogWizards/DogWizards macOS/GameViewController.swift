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
    
    // MARK: - View Life Cycle

    override func loadView() {
        view = GameView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        (view as! GameView).start()

        preferredContentSize = NSSize(width: 800, height: 600)
    }

}

