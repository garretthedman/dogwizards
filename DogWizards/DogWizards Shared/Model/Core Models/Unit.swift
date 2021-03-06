//
//  Unit.swift
//  DogWizards
//
//  Created by Andrew Finke on 4/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

/// Core object for representing a unit and how it should be displayed
enum Unit: CaseIterable {

    case mouse, pancake, rock, tooth, pizza, kona, dolphin, unicorn, start

    case nm, mm, cm, m, km

    var displayString: String {
        switch self {
        case .mouse: return "Mouse"
        case .pancake: return "Pancake"
        case .rock: return "Rock"
        case .tooth: return "Tooth"
        case .pizza: return "Pizza"
        case .kona: return "Kona"
        case .dolphin: return "Dolphin"
        case .unicorn: return "Unicorn"
        case .start: return "Start"
        case .nm: return "nm"
        case .mm: return "mm"
        case .cm: return "cm"
        case .m: return "m"
        case .km: return "km"
        }
    }
    
    var displayStringImage: String{
        switch self {
            case .mouse: return "🐁"
            case .pancake: return "🥞"
            case .rock: return "🗿"
            case .tooth: return "🦷"
            case .pizza: return "🍕"
            case .kona: return "🐶"
            case .dolphin: return "🐬"
            case .unicorn: return "🦄"
            case .start: return "?"
            
            case .mm: return "mm"
            case .cm: return "cm"
            case .km: return "km"
            case .m: return "m"
            case .nm: return "nm"
            
        default: return "XXXXX"
        }
    }
}
