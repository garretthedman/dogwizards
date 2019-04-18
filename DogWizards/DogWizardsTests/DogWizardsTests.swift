//
//  DogWizardsTests.swift
//  DogWizardsTests
//
//  Created by Andrew Finke on 4/17/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import XCTest

@testable import DogWizards

class DogWizardsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDrop() {
        let cardOne = CardModel(topUnit: .dolphin, bottomUnit: .dolphin)
        let cardTwo = CardModel(topUnit: .kona, bottomUnit: .kona)
        let cardThree = CardModel(topUnit: .mouse, bottomUnit: .mouse)
        let cardFour = CardModel(topUnit: .pancake, bottomUnit: .pancake)

        let model = CastModel(size: 6)
        XCTAssertEqual(model.cards, [nil, nil, nil, nil, nil, nil])

        model.prepareForDrop(at: 1, from: .left)
        XCTAssertEqual(model.cards, [nil, nil, nil, nil, nil, nil])
        let _ = model.drop(card: cardOne, at: 1)
        XCTAssertEqual(model.cards, [nil, cardOne, nil, nil, nil, nil])

        model.prepareForDrop(at: 1, from: .right)
        XCTAssertEqual(model.cards, [nil, nil, cardOne, nil, nil, nil])
        let _ = model.drop(card: cardTwo, at: 1)
        XCTAssertEqual(model.cards, [nil, cardTwo, cardOne, nil, nil, nil])

        model.prepareForDrop(at: 2, from: .right)
        XCTAssertEqual(model.cards, [nil, cardTwo, nil, cardOne, nil, nil])
        let _ = model.drop(card: cardThree, at: 2)
        XCTAssertEqual(model.cards, [nil, cardTwo, cardThree, cardOne, nil, nil])

        model.prepareForDrop(at: 2, from: .left)
        XCTAssertEqual(model.cards, [cardTwo, cardThree, nil, cardOne, nil, nil])
        let _ = model.drop(card: cardFour, at: 2)
        XCTAssertEqual(model.cards, [cardTwo, cardThree, cardFour, cardOne, nil, nil])
    }
}
