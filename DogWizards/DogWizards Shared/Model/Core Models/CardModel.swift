//
//  CardModel.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

class CardModel: CustomStringConvertible, Equatable {

    // MARK: - Types
    
    enum CastState {
        case uncasted, correctlyCast, incorrectlyCast
    }

    enum Update {
        case cast(CastState), flipped
    }

    enum CardUnits {
        case one(Unit), two(top: Unit, bottom: Unit)
    }

    // MARK: - Properties

    var units: CardUnits

    private let uuid = UUID()

    var didUpdate: ((Update) -> Void)?
    var castState = CastState.uncasted {
        didSet {
            didUpdate?(.cast(castState))
        }
    }

    // MARK: - Initialization

    init(units: CardUnits) {
        self.units = units
    }

    // MARK: - Helpers

    func flip() {
        switch units {
        case .one(_):
            didUpdate?(.flipped)
        case .two(let top, let bottom):
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
