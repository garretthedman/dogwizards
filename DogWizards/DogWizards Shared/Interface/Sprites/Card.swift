//
//  Card.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

/// A card sprite. Likely used view subclasses and not directly instantiated
class Card: SKSpriteNode {

    // MARK: Properties

    /// the card's model
    public let model: CardModel

    // MARK: - Initialization

    init(texture: SKTexture?, color: SKColor, size: CGSize, model: CardModel) {
        self.model = model
        super.init(texture: texture, color: color, size: size)
        setupInterface()
    }

    convenience init(model: CardModel) {
        let width = Design.cardSizeWidth
        let height = width * Design.cardSizeRatio
        let size = CGSize(width: width, height: height)
        let texture = SKTexture(imageNamed: "Card")
        self.init(texture: texture,
                  color: .white,
                  size: size,
                  model: model)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface

    /// to be implemented by subclasses
    public func setupInterface() {
        fatalError("not implemented")
    }

    /// to be implemented by subclasses
    public func updateLabels() {
        fatalError("not implemented")
    }

}
