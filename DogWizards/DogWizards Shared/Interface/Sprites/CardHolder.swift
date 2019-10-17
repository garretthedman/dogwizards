//
//  CardHolder.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A sprite indicating a user can drop a card on it
class CardHolder: SKSpriteNode {

    // MARK: - Properties -

    var fullFillShape: SKShapeNode?
    var upperFillShape: SKShapeNode?
    var lowerFillShape: SKShapeNode?

    // MARK: - Initialization

    init() {
        let width = Design.cardHolderSizeWidth
        let height = width * Design.cardHolderSizeRatio
        super.init(texture: SKTexture(imageNamed: "Card Holder"),
                  color: .clear,
                  size: CGSize(width: width, height: height))

        let upperFillShapeRect = CGRect(x: -size.width / 2, y: 0, width: size.width, height: size.height / 2)
        let upperFillShape = SKShapeNode(rect: upperFillShapeRect, cornerRadius: Design.cardHolderFillShapeCornerRadius)
        upperFillShape.alpha = 0.0
        addChild(upperFillShape)
        self.upperFillShape = upperFillShape

        let lowerFillShapeRect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height / 2)
        let lowerFillShape = SKShapeNode(rect: lowerFillShapeRect, cornerRadius: Design.cardHolderFillShapeCornerRadius)
        lowerFillShape.alpha = 0.0
        addChild(lowerFillShape)
        self.lowerFillShape = lowerFillShape

        let fullFillShapeRect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        let fullFillShape = SKShapeNode(rect: fullFillShapeRect, cornerRadius: Design.cardHolderFillShapeCornerRadius)
        fullFillShape.alpha = 0.0
        addChild(fullFillShape)
        self.fullFillShape = fullFillShape
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
