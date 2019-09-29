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
        case shift, castResult(Unit?)
    }

    // MARK: - Properties

    /// the current start unit of the cast
    var startUnit: Unit
    
    let endUnit: Unit
    
    /// the user cards in the cast (not including the start unit)
    var cards: [CardModel?]

    /// Closure for informing listener (usually the level scene) of an update
    var didUpdate: ((Update) -> Void)?

    // MARK: - Initialization

    init(startUnit: Unit, endUnit: Unit, size: Int) {
        self.startUnit = startUnit
        self.endUnit = endUnit
        cards = [CardModel?](repeating: nil, count: size)
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
            previousUnit = startUnit
        } else {
            // get the previous card's unit
            guard let previousCastCard = cards[index - 1] else { return nil }
            switch previousCastCard.units {
            case .one(let unit):
                // a one unit card would be that unit
                previousUnit = unit
            case .two(let top, _):
                // a two unit card would be the top unit
                previousUnit = top
            }
        }

        switch castCard.units {
        case .one(let unit):
            // if this card has one unit, compare to that unit
            return previousUnit == unit ? .correctlyCast : .incorrectlyCast
        case .two(_, let bottom):
            // if this card has two units, compare to it's bottom unit
            return previousUnit == bottom ? .correctlyCast : .incorrectlyCast
        }
    }

    /// cast the card at the specified index in the cast model
    func cast(at index: Int) {
        // make sure we can cast this card
        guard let castCard = cards[index], let castState = potentialCastResult(at: index) else { return }
        castCard.castState = castState

        // get the units of the last card to be correctly cast
        guard let lastCorrectCardUnits = cards.last(where: { $0?.castState == .correctlyCast })??.units else {
            // no card has been correctly cast, so we have no result
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
    
    func isCastSuccessful() -> Bool {
        let compacted = cards.compactMap { $0 }
        guard compacted.filter({ $0.castState != CardModel.CastState.correctlyCast }).isEmpty,
            let lastCardUnits = compacted.last?.units else {
            return false
        }
        
        switch lastCardUnits {
        case .one(let unit):
            return endUnit == unit
        case .two(let top,_):
            return endUnit == top
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
        Logging.shared.log(event: .spellsStartedZag, description: cards.description)
    }

    // MARK: - Dragging

    /// remove a card from the cast model
    func pickUp(card: Card) {
        guard let index = cards.firstIndex(of: card.model) else { return }
        let cardDescription = cards[index]?.description ?? "??"
        cards[index] = nil
        Logging.shared.log(event: .spellRemoved, description: cardDescription + ", now: \(cards)")
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
            Logging.shared.log(event: .spellAdded, description: card.description + ", now: \(cards)")
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

