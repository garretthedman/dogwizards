//
//  PanGestureRecognizerMetadata.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation
import CoreGraphics

class PanGestureRecognizerMetadata {
    var card: Card
    var lastLocation: CGPoint

    init(card: Card, lastLocation: CGPoint) {
        self.card = card
        self.lastLocation = lastLocation
    }
}
