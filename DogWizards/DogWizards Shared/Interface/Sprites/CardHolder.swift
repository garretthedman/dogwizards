//
//  CardHolder.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class CardHolder: SKSpriteNode {

    // MARK: - Initialization

    init() {
        let width = Design.cardHolderSizeWidth
        let height = width * Design.cardHolderSizeRatio
        super.init(texture: SKTexture(imageNamed: "Card Holder"),
                  color: .clear,
                  size: CGSize(width: width, height: height))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
