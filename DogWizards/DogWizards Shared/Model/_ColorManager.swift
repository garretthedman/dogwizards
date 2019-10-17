//
//  _ColorManager.swift
//  DogWizards
//
//  Created by Andrew Finke on 10/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation
import SpriteKit

class _ColorManager {
    private var colors = [Unit: SKColor]()
    func color(for unit: Unit) -> SKColor {
        if let existing = colors[unit] {
            return existing
        } else {
            let random = SKColor(red: CGFloat.random(in: 0..<255) / 255.0,
                                 green: CGFloat.random(in: 0..<255) / 255.0,
                                 blue: CGFloat.random(in: 0..<255) / 255.0,
                                 alpha: 1.0)
            colors[unit] = random
            return random
        }
    }
}
