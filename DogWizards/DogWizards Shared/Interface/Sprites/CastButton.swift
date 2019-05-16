//
//  CastButton.swift
//  DogWizards
//
//  Created by Andrew Finke on 5/15/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {

    // MARK: Properties

    let label: SKLabelNode

    // MARK: - Initialization

    init(text: String) {
        let size = CGSize(width: Design.buttonWidth, height: Design.buttonHeight)

        label = SKLabelNode(text: text)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .black

        super.init(texture: nil,
                  color: .white,
                  size: size)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface

    public func setupInterface() {
        fatalError("not implemented")
    }

}
