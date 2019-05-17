//
//  CardModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

/// Model representing a card
class CardModel: CustomStringConvertible, Equatable {

    // MARK: - Types

    /// Enum for communicating how the card was updated
    enum Update {
        case cast(CastState), flipped
    }

    /// Enum for tracking cast state
    enum CastState {
        case uncasted, correctlyCast, incorrectlyCast
    }

    /// Enum for saying the type of units of a card
    enum CardUnits {
        /// Indicates a card supports one unit
        case one(Unit)
        /// A card that supports two units
        case two(top: Unit, bottom: Unit)
    }

    // MARK: - Properties

    /// The unit(s) of this card
    var units: CardUnits

    /// The uuid of the card for tracking equality
    private let uuid = UUID()

    /// Closure for informing listener (usually a sprite) of an update
    var didUpdate: ((Update) -> Void)?

    /// Tracks cast state of the card
    var castState = CastState.uncasted {
        didSet {
            // update listener of a cast state change
            didUpdate?(.cast(castState))
        }
    }

    // MARK: - Initialization

    init(units: CardUnits) {
        self.units = units
    }

    // MARK: - Helpers

    /// flips the units of the card
    func flip() {
        switch units {
        case .one(_):
            // can't flip one unit
            didUpdate?(.flipped)
        case .two(let top, let bottom):
            // flips the top and bottom
            units = .two(top: bottom, bottom: top)
            didUpdate?(.flipped)
        }
    }

    // MARK: - CustomStringConvertible

    var description: String {
        switch units {
        case .one(let unit):
            return unit.displayString
        case .two(let top, let bottom):
            return top.displayString
                + " / "
                + bottom.displayString
        }
    }

    // MARK: - Equatable

    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
