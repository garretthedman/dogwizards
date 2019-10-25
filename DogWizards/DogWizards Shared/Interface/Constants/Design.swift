//
//  Design.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import CoreGraphics
import Foundation

// use the correct interface framework depending on if running on iOS or macOS
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// ideally, all design type constants should be in this file for quick changes
struct Design {
    static let cardTwoUnitFontSize = CGFloat(26)
    static let cardTwoUnitFontName = "Avenir"

    static let cardSingleUnitFontSize = CGFloat(26)
    static let cardSingleUnitFontName = "Avenir"

    static let cardSizeRatio = CGFloat(3.5 / 2.5)
    static let cardFlipButtonCushion = CGFloat(15)

    static let cardSizeWidth = CGFloat(120)
    static let cardPaddingSize = CGFloat(40)

    static let cardHolderSizeRatio = CGFloat(1.3)
    static let cardHolderSizeWidth = CGFloat(145)
    static let cardHolderPaddingSize = CGFloat(10)

    static let cardHolderFillShapeCornerRadius = CGFloat(10)

    static let cardShiftScale = CGFloat(0.95)
    static let cardShiftRotation = CGFloat.pi / 16

    static let cardPickUpScale = CGFloat(0.8)
    static let cardPickUpAlpha = CGFloat(0.9)

    static let buttonWidth = CGFloat(180)
    static let buttonHeight = CGFloat(60)

    static let backgroundColor = #colorLiteral(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    static let sceneSize = CGSize(width: 1400, height: 1050)

    static let showSingleUnit = false
}

