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

/// Model for tracking the state of cards before/during a cast
class CastModel {

    // MARK: - Types

    /// Enum for communicating how the cast was updated
    enum Update {
        case shift, castResult(CardValue?)
    }

    // MARK: - Properties

    private var quantity: CGFloat

    /// the current start unit of the cast
    var startValue: CardValue
    
    let endUnit: Unit
    
    /// the user cards in the cast (not including the start unit)
    var cards: [CardModel?]

    /// Closure for informing listener (usually the level scene) of an update
    var didUpdate: ((Update) -> Void)?

    // MARK: - Initialization

    init(startValue: CardValue, endUnit: Unit, size: Int) {
        self.startValue = startValue
        self.endUnit = endUnit
        self.cards = [CardModel?](repeating: nil, count: size)
        self.quantity = startValue.quantity
    }

    // MARK: - Helpers

    /// index of a card in the cast
    func index(of card: CardModel) -> Int? {
        return cards.firstIndex(of: card)
    }

    // MARK: - Casting

    /// resets all the cards' cast state
    func resetCardCastStates() {
        didUpdate?(.castResult(nil))
        cards.forEach { $0?.castState = CardModel.CastState.uncasted }
        quantity = startValue.quantity
    }

    /// returns if this is the next card to be casted
    func isCardNextInChain(at index: Int) -> Bool {
        let flattenCards = cards.compactMap { $0 }
        for (cardIndex, card) in flattenCards.enumerated() where cardIndex < index && card.castState != .correctlyCast {
            // found a card before this one that hasn't been casted correctly
            return false
        }

        return true
    }

    /// returns what the cast result would be for the card at the specified index
    func potentialCastResult(at index: Int) -> CardModel.CastState? {
        guard isCardNextInChain(at: index), let castCard = cards[index] else { return nil }
        let previousUnit: Unit
        if index == 0 {
            // if this is the first card, then the previous unit was the start unit
            previousUnit = startValue.unit
        } else {
            // get the previous card's unit
            guard let previousCastCard = cards[index - 1] else { return nil }
            switch previousCastCard.values {
            case .one(let value):
                // a one unit card would be that unit
                previousUnit = value.unit
            case .two(let top, _):
                // a two unit card would be the top unit
                previousUnit = top.unit
            }
        }

        switch castCard.values {
        case .one(let value):
            // if this card has one unit, compare to that unit
            return previousUnit == value.unit ? .correctlyCast : .incorrectlyCast
        case .two(_, let bottom):
            // if this card has two units, compare to it's bottom unit
            return previousUnit == bottom.unit ? .correctlyCast : .incorrectlyCast
        }
    }

    /// cast the card at the specified index in the cast model
    func cast(at index: Int) {
        print(#function)
        // make sure we can cast this card
        guard let castCard = cards[index], let castState = potentialCastResult(at: index) else { return }
        castCard.castState = castState

        // get the values of the last card to be correctly cast
        guard let lastCorrectCardValues = cards.last(where: { $0?.castState == .correctlyCast })??.values else {
            // no card has been correctly cast, so we have no result
            didUpdate?(.castResult(nil))
            return
        }

        switch lastCorrectCardValues {
        case .one(let value):
            quantity = quantity * value.quantity
            didUpdate?(.castResult(CardValue(unit: value.unit, quantity: quantity)))
        case .two(let top, let bottom):
            quantity = quantity * top.quantity / bottom.quantity
            didUpdate?(.castResult(CardValue(unit: top.unit, quantity: quantity)))
        }
    }
    
    func isCastSuccessful() -> Bool {
        let compacted = cards.compactMap { $0 }
        guard compacted.filter({ $0.castState != CardModel.CastState.correctlyCast }).isEmpty,
            let lastCardValues = compacted.last?.values else {
            return false
        }
        
        switch lastCardValues {
        case .one(let value):
            return endUnit == value.unit
        case .two(let top,_):
            return endUnit == top.unit
        }
    }

    /// remove any empty slots to the left of each card in prep for the cast
    func prepareForCast() {
        let compacted = cards.compactMap { $0 }
        let previousCards = cards

        cards = [CardModel?](repeating: nil, count: cards.count)
        for (index, card) in compacted.enumerated() {
            cards[index] = card
        }

        if cards != previousCards {
            // if the new compacted version is diff than the previous, then update the listner that we shifted the position of some cards
            didUpdate?(.shift)
        }
        Logging.shared.log(event: .spellsStartedZag)
    }

    // MARK: - Dragging

    /// remove a card from the cast model
    func pickUp(card: Card) {
        guard let index = cards.firstIndex(of: card.model) else { return }
        let cardDescription = cards[index]?.description ?? "??"
        cards[index] = nil
        Logging.shared.log(event: .spellRemoved, description: cardDescription)
    }

    /// clear the space in prep for a card drop from a specified direction
    func prepareForDrop(at index: Int, from direction: Direction) {
        guard let freeIndex = firstFreeIndex(startingAt: index, from: direction) else {
            return
        }

        // push cards out of the way in the correct direction
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

    /// insert the card into the card model at the index (if space)
    func drop(card: CardModel, at index: Int) -> Bool {
        if !cards.contains(card) && cards[index] == nil {
            cards[index] = card
            // there was space, drop was successful
            Logging.shared.log(event: .spellAdded, description: card.description)
            return true
        } else {
            // no space, card not dropped
            return false
        }
    }

    /// find the first free index to push cards towards to prep the insertion of a new card
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

