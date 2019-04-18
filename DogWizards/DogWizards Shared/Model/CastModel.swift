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

    // MARK: - Properties

    var cards: [CardModel?]
    var didShift: (() -> Void)?

    // MARK: - Initialization

    init(size: Int) {
        cards = [CardModel?](repeating: nil, count: size)
    }

    // MARK: - Helpers

    func prepareForCast() {
        let compacted = cards.compactMap { $0 }
        let previousCards = cards

        cards = [CardModel?](repeating: nil, count: cards.count)
        for (index, card) in compacted.enumerated() {
            cards[index] = card
        }

        if cards != previousCards {
            didShift?()
        }
    }

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
            didShift?()
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
