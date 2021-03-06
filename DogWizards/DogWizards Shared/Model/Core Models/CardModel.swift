//
//  CardModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation
import CoreGraphics

struct Measurement {
    let quantity: CGFloat
    let unit: Unit
    init(unit: Unit, quantity: CGFloat = 1) {
        self.unit = unit
        self.quantity = quantity
    }

    var displayString: String {
        let quantityString: String
        if Design.showSingleUnit {
            quantityString = quantity.description + " "
        } else if quantity != 1 {
            quantityString = quantity.description + " "
        } else {
            quantityString = ""
        }
        return quantityString + unit.displayStringImage
    }
}

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

    /// Enum for saying the type of values of a card
    enum CardValues {
        /// Indicates a card supports one unit
        case one(Measurement)
        /// A card that supports two units
        case two(top: Measurement, bottom: Measurement)
    }

    // MARK: - Properties

    /// Closure for informing listener (usually a sprite) of an update
    var didUpdate: ((Update) -> Void)?
    
    /// Tracks cast state of the card
    var castState = CastState.uncasted {
        didSet {
            // update listener of a cast state change
            didUpdate?(.cast(castState))
        }
    }
    
    /// The values(s) of this card
    var values: CardValues

    /// The uuid of the card for tracking equality
    private let uuid = UUID()


    // MARK: - Initialization

    init(values: CardValues) {
        self.values = values
    }

    // MARK: - Helpers

    /// flips the units of the card
    func flip() {
        switch values {
        case .one(_):
            // can't flip one unit
            didUpdate?(.flipped)
        case .two(let top, let bottom):
            // flips the top and bottom
            values = .two(top: bottom, bottom: top)
            didUpdate?(.flipped)
        }

        Logging.shared.log(event: .spellFlipped, description: description)
    }

    // MARK: - CustomStringConvertible

    var description: String {
        switch values {
        case .one(let value):
            return value.displayString
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
