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
typealias GameViewPanGestureRecognizer = UIPanGestureRecognizer
typealias GameViewTapGestureRecognizer = UITapGestureRecognizer
typealias GameViewPanGestureRecognizerState = UIPanGestureRecognizer.State
#elseif os(macOS)
import AppKit
typealias GameViewPanGestureRecognizer = NSPanGestureRecognizer
typealias GameViewTapGestureRecognizer = NSClickGestureRecognizer
typealias GameViewPanGestureRecognizerState = NSPanGestureRecognizer.State
#endif

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

