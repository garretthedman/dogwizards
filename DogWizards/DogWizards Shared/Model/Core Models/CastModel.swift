//
//  Model.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

enum Direction {
    case left, right
}

class CastModel {

    // MARK: - Types

    enum Update {
        case shift, castResult(Unit?)
    }

    // MARK: - Properties

    var startUnit: Unit
    var cards: [CardModel?]
    var didUpdate: ((Update) -> Void)?

    // MARK: - Initialization

    init(startUnit: Unit, size: Int) {
        self.startUnit = startUnit
        cards = [CardModel?](repeating: nil, count: size)
    }

    // MARK: - Helpers

    func index(of card: CardModel) -> Int? {
        return cards.firstIndex(of: card)
    }

    // MARK: - Casting

    func resetCardCastStates() {
        didUpdate?(.castResult(nil))
        cards.forEach { $0?.castState = CardModel.CastState.uncasted }
    }

    func firstNonCorrectCast() -> CardModel? {
        let flattenCards = cards.compactMap { $0 }
        for card in flattenCards where card.castState != .correctlyCast {
            return card
        }
        return nil
    }

    func isCardNextInChain(at index: Int) -> Bool {
        let flattenCards = cards.compactMap { $0 }
        for (cardIndex, card) in flattenCards.enumerated() where cardIndex < index && card.castState != .correctlyCast {
            return false
        }

        return true
    }

    func cast(at index: Int) {
        guard isCardNextInChain(at: index) else { fatalError() }

        guard let castCard = cards[index] else { return }
        let previousUnit: Unit
        if index == 0 {
            previousUnit = startUnit
        } else {
            guard let previousCastCard = cards[index - 1] else { return }
            switch previousCastCard.units {
            case .one(let unit):
                previousUnit = unit
            case .two(let top, _):
                previousUnit = top
            }
        }

        switch castCard.units {
        case .one(let unit):
            castCard.castState = previousUnit == unit ? .correctlyCast : .incorrectlyCast
        case .two(_, let bottom):
            castCard.castState = previousUnit == bottom ? .correctlyCast : .incorrectlyCast
        }

        guard let lastCorrectCardUnits = cards.last(where: { $0?.castState == .correctlyCast })??.units else {
            didUpdate?(.castResult(nil))
            return
        }

        switch lastCorrectCardUnits {
        case .one(let unit):
             didUpdate?(.castResult(unit))
        case .two(let top, _):
             didUpdate?(.castResult(top))
        }
    }

    func prepareForCast() {
        let compacted = cards.compactMap { $0 }
        let previousCards = cards

        cards = [CardModel?](repeating: nil, count: cards.count)
        for (index, card) in compacted.enumerated() {
            cards[index] = card
        }

        if cards != previousCards {
            didUpdate?(.shift)
        }
    }

    // MARK: - Dragging

    func pickUp(card: Card) {
        guard let index = cards.firstIndex(of: card.model) else { return }
        cards[index] = nil
    }

    func prepareForDrop(at index: Int, from direction: Direction) {
        guard let freeIndex = firstFreeIndex(startingAt: index, from: direction) else {
            return
        }

        var shiftedCards = false
        var movedIndex = freeIndex
        while movedIndex != index {
            let increment = direction == .left ? 1 : -1
            let cardToShift = cards[movedIndex + increment]
            if cardToShift != nil {
                shiftedCards = true
            }
            cards[movedIndex] = cardToShift
            movedIndex += increment
        }

        cards[index] = nil
        if shiftedCards {
            didUpdate?(.shift)
        }
    }

    func drop(card: CardModel, at index: Int) -> Bool {
        if !cards.contains(card) && cards[index] == nil {
            cards[index] = card
            return true
        } else {
            return false
        }
    }

    private func firstFreeIndex(startingAt index: Int, from direction: Direction) -> Int? {
        var checkedIndex = index
        while checkedIndex >= 0 && checkedIndex < cards.count {
            if cards[checkedIndex] == nil {
                return checkedIndex
            }
            if direction == .left {
                checkedIndex -= 1
            } else {
                checkedIndex += 1
            }
        }
        return nil
    }
}
