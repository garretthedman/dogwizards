//
//  Unit.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

enum Unit: CaseIterable {

    case mouse, pancake, rock, tooth, pizza, kona, dolphin, unicorn

    var displayString: String {
        switch self {
        case .mouse: return "🐁"
        case .pancake: return "🥞"
        case .rock: return "🗿"
        case .tooth: return "🦷"
        case .pizza: return "🍕"
        case .kona: return "🐶"
        case .dolphin: return "🐬"
        case .unicorn: return "🦄"
        }
    }
}
