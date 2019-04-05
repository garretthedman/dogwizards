//
//  Card.swift
//  CatWizards
//
//  Created by Garrett.Hedman on 2/6/19.
//  Copyright © 2019 Garrett Hedman. All rights reserved.
//

import Foundation
import SpriteKit

class Card: SKSpriteNode {
    
    public var numerator : String = "Cat"
    public var denominator: String = "Dog"
    public var isFlipped : Int = 0
    
    //variable that indicates if it's part of the chain being build
    public var inChain : Int = 0
    
    //variable indicating what position in the chain it is at (starting is 0)
    public var inChainAt : Int = 0

}
