//
//  AnimationDuration.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/18/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

/// ideally, all animation type constants should be in this file for quick changes
struct AnimationDuration {
    static let cardShift = TimeInterval(0.25)
    static let cardFlip = TimeInterval(0.25)
    static let cardPickUp = TimeInterval(0.1)
    static let cardMoveToHolder = TimeInterval(0.2)
    static let startButtonMove = TimeInterval(0.15)

    static let holderFillViewsFade = TimeInterval(0.5)
    static let holderFillViewsWait = TimeInterval(4)
}
