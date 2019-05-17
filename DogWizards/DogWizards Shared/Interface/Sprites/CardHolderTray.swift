//
//  CardHolderTray.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/18/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A sprite that contains holders for cards
class CardHolderTray: SKSpriteNode {

    // MARK: - Properties

    var holders = [CardHolder]()

    // MARK: - Initialization

    init(holderCount: Int) {
        // dynamically calculate size based on number of cards
        let holderSize = Design.cardHolderSizeWidth + Design.cardHolderPaddingSize
        let width = holderSize * CGFloat(holderCount) - Design.cardHolderPaddingSize
        let height = Design.cardHolderSizeWidth * Design.cardHolderSizeRatio

        super.init(texture: nil,
                   color: .clear,
                   size: CGSize(width: width, height: height))

        anchorPoint = CGPoint(x: 0, y: 0)

        for index in 0..<holderCount {
            let holder = CardHolder()
            let xPosition = holderSize * CGFloat(index)
                + Design.cardHolderSizeWidth / 2
            holder.position = CGPoint(x: xPosition, y: height / 2)
            addChild(holder)
            holders.append(holder)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

