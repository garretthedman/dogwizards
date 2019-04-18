//
//  Extensions.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
typealias GameScenePanGestureRecorgnizer = UIPanGestureRecognizer
typealias GameSceneTapGestureRecorgnizer = UITapGestureRecognizer
typealias GameScenePanGestureRecorgnizerState = UIPanGestureRecognizer.State
#elseif os(macOS)
import AppKit
typealias GameScenePanGestureRecorgnizer = NSPanGestureRecognizer
typealias GameSceneTapGestureRecorgnizer = NSClickGestureRecognizer
typealias GameScenePanGestureRecorgnizerState = NSPanGestureRecognizer.State
#endif

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}


