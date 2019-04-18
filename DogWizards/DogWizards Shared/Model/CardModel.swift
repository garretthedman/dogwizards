//
//  CardModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

class CardModel: CustomStringConvertible, Equatable {

    // MARK: - Properties

    var topUnit: Unit
    var bottomUnit: Unit
    var didFlip: (() -> Void)?
    private let uuid = UUID()

    // MARK: - Initialization

    init(topUnit: Unit, bottomUnit: Unit) {
        self.topUnit = topUnit
        self.bottomUnit = bottomUnit
    }

    // MARK: - Helpers

    func flip() {
        let previousTopUnit = topUnit
        topUnit = bottomUnit
        bottomUnit = previousTopUnit
        didFlip?()
    }

    // MARK: - CustomStringConvertible

    var description: String {
        return topUnit.displayString
            + " / "
            + bottomUnit.displayString
    }

    // MARK: - Equatable

    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
