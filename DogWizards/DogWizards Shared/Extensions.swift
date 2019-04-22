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
typealias GameViewPanGestureRecorgnizer = UIPanGestureRecognizer
typealias GameViewTapGestureRecorgnizer = UITapGestureRecognizer
typealias GameViewPanGestureRecorgnizerState = UIPanGestureRecognizer.State
#elseif os(macOS)
import AppKit
typealias GameViewPanGestureRecorgnizer = NSPanGestureRecognizer
typealias GameViewTapGestureRecorgnizer = NSClickGestureRecognizer
typealias GameViewPanGestureRecorgnizerState = NSPanGestureRecognizer.State
#endif

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}


