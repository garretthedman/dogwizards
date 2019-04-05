    //
    //  GameScene.swift
    //  Template
    //
    //  Created by Garrett.Hedman on 2/5/19.
    //  Copyright © 2019 Garrett Hedman. All rights reserved.
    //
    
    import SpriteKit
    import GameplayKit
    
    class GameScene: SKScene {
        
        //GAME VARIABLES
        
        //Log properties
        var logTotalFlips : Int = 0
        var logMutableConversions : Int = 0
        
        //Add properties of Game first
        var deckOfCards : [Card] = []
        //Array that holds references for number of cards in
        var chainReferenceArray : [Int] = []
        //Array that holds value of all possible places for cards
        //10 is nil
        var fixedChainReferenceArray : [Int]  = [10,10,10,10,10,10,10,10]
        var chainArea : SKSpriteNode?
        var startCard : SKNode?
        var castObject : SKLabelNode?
        var castButton : SKSpriteNode?
        var solutionChecker : SKLabelNode?
        var testLable : SKLabelNode?
        
        //touch functions
        var touchLocation = CGPoint()
        let tapCast = UITapGestureRecognizer()
        let tapRec2 = UITapGestureRecognizer()
        let panHold = UIPanGestureRecognizer()
        var chainCount = 0
        var foundCard = -1
        
        //chain location
        var chainStartXPos = -582 //location of first card in chain
        var widthOfCard = 128
        var spacingOfCards = 6
        
        //castModeOn
        var castModeOn = 0
        //values of the path to trace
        var castPath = [Int]()
        var castLoop = 0
        
        //INITIALIZATION -- Like view didLoad
        override func didMove(to view: SKView) {
            
            tapCast.addTarget(self, action:#selector(GameScene.tapButton))
            view.addGestureRecognizer(tapCast)
            
            tapRec2.addTarget(self, action:#selector(GameScene.doubleTap))
            tapRec2.numberOfTouchesRequired = 1
            tapRec2.numberOfTapsRequired = 2
            view.addGestureRecognizer(tapRec2)
            
            panHold.addTarget(self, action: #selector(GameScene.panHoldView(_:)))
            view.addGestureRecognizer(panHold)
            
            self.setupScene()
            
        }
        
        //SETUP AT START
        //reates a deck of cards whose numerator, denominator, and name are attached to the viewable cards.
        func setupScene(){
            
            chainArea = self.childNode(withName: "chainArea") as? SKSpriteNode
            castButton = self.childNode(withName: "castButton") as? SKSpriteNode
            startCard = self.childNode(withName: "startCard")
            castObject = self.childNode(withName: "castObject") as? SKLabelNode
            
            for node in self.children{
                
                //Add all cards to a deck of cards
                if (node.name == "Card"){
                    
                    //create empty object card
                    let newCard = node as? Card
                    
                    //set initial values of numerator and denominator
                    let numLabel = node.childNode(withName: "numerator") as? SKLabelNode
                    let demLabel = node.childNode(withName: "denominator") as? SKLabelNode
                    newCard?.numerator = numLabel?.text ?? ""
                    newCard?.denominator = demLabel?.text ?? ""
                    newCard?.name = "Card"
                    
                    //add cards to deck
                    deckOfCards.append(newCard ?? Card())
                    
                }
            }
        }
        
        func findCard()->Int{
            for index in 0...(deckOfCards.count-1){
                if nodes(at: touchLocation).contains(deckOfCards[index]){
                    foundCard = 1
                    deckOfCards[index].zPosition = 1
                    return index
                }
            }
            return -1
        }
        
        //TOUCHES
        //doubleTap - flips card
        //panHold - moves around card
        //tap - cast button
        
        @objc func tapButton(_ sender:UITapGestureRecognizer){
            
            let touchPoint = sender.location(in: sender.view)
            touchLocation = convertPoint(fromView: touchPoint)
            
            if nodes(at: touchLocation).contains(castButton!){
                
                condenseSpellChain()
                if checkIfValidChain(index: 0){
                    //Turns off cast mode
                    if castModeOn == 1{
                        castModeOn = 0
                        castPath.removeAll()
                        let objectLabel : SKLabelNode? = self.childNode(withName: "castObject") as? SKLabelNode
                        objectLabel?.text = ""
                        resetColor()
                    }
                        //turns on cast mode
                    else{
                        castModeOn = 1
                        //creates a cast path
                        createCastPath()
                        //resets cast loop
                        castLoop = 0
                        print(castPath)
                    }
                }else{
                    checkChain()
                    //print("Chain has problems")
                }
            }
        }
        
        @objc func doubleTap(_ sender:UIRotationGestureRecognizer){
            
            //handeling touches
            let touchPoint = sender.location(in: sender.view)
            touchLocation = convertPoint(fromView: touchPoint)
            
            for i in 0...(deckOfCards.count-1){
                if nodes(at: touchLocation).contains(deckOfCards[i]){
                    let card = deckOfCards[i]
                    let oldDenominator = card.denominator
                    let oldNumerator = card.numerator
                    card.numerator = oldDenominator
                    card.denominator = oldNumerator
                    
                    //countflips
                    logTotalFlips += 1
                    print("Flip total is: \(logTotalFlips)")
                    
                    //change image of card
                    updateCardImage()
                    updateStart()
                }
            }
        }
        
        @objc func panHoldView(_ sender:UIPanGestureRecognizer){
            
            //handeling touches
            let touchPoint = sender.location(in: sender.view)
            let newLocation = convertPoint(fromView: touchPoint)
            
            //set touch location to newLocation at beginning (because card position is dependent on OG touch
            if(sender.state == .began){
                touchLocation = newLocation
            }
            
            if castModeOn == 0{
                //if already touching then just move card initially touched
                if foundCard > -1{
                    let card = deckOfCards[foundCard]
                    let newX = card.position.x + newLocation.x - touchLocation.x
                    let newY = card.position.y + newLocation.y - touchLocation.y
                    card.position = CGPoint(x: newX, y: newY)
                    updateChain(cardPoint: card.position)
                } else{
                    
                    //see if your on something
                    foundCard = findCard()
                    
                    //if touching then move
                    if foundCard > -1{
                        let card = deckOfCards[foundCard]
                        let newX = card.position.x + newLocation.x - touchLocation.x
                        let newY = card.position.y + newLocation.y - touchLocation.y
                        card.position = CGPoint(x: newX, y: newY)
                        updateChain(cardPoint: card.position)
                    }
                }
                
                touchLocation = newLocation
                
                //reset found card
                if(sender.state == .ended){
                    
                    //reset order of touched card
                    if (foundCard > -1){
                        snapCard()
                        deckOfCards[foundCard].zPosition = 0
                        foundCard = -1
                    }
                }
            }
                
                //When castmode is on
            else{
                
                if(sender.state == .changed){
                    touchLocation = newLocation
                }
                
                //at start of castPath
                if castPath.isEmpty{
                    print("bad cast")
                }
                    
                else if castPath[0] == -1{
                    if nodes(at: touchLocation).contains(startCard!){
                        let solutionLabel : SKLabelNode? = startCard?.childNode(withName: "startLabel") as? SKLabelNode
                        solutionLabel?.fontColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                        let objectLabel : SKLabelNode? = self.childNode(withName: "castObject") as? SKLabelNode
                        objectLabel?.text = solutionLabel?.text
                        castPath.remove(at: 0)
                        print(castPath)
                    }
                }
                
                //at denominator
                if castLoop == 0 {
                    let card = deckOfCards[castPath[0]]
                    if nodes(at:touchLocation).contains(card.childNode(withName: "denominator")!){
                        let newDenominator : SKLabelNode? = card.childNode(withName: "denominator") as? SKLabelNode
                        newDenominator?.fontColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                        
                        //update object
                        let objectLabel : SKLabelNode? = self.childNode(withName: "castObject") as? SKLabelNode
                        objectLabel?.text = newDenominator?.text
                        
                        //set back numerator
                        castLoop = 1
                        print(castPath)
                    }
                }
                
                //at numerator
                if castLoop == 1 {
                    let card = deckOfCards[castPath[0]]
                    if nodes(at:touchLocation).contains(card.childNode(withName: "numerator")!){
                        let newNumerator : SKLabelNode? = card.childNode(withName: "numerator") as? SKLabelNode
                        newNumerator?.fontColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                        
                        //update object
                        let objectLabel : SKLabelNode? = self.childNode(withName: "castObject") as? SKLabelNode
                        objectLabel?.text = newNumerator?.text
                        
                        //set back denominator
                        castLoop = 0
                        
                        //remove three spots of array
                        for _ in 0...2{
                            castPath.remove(at: 0)
                            print(castPath)
                        }
                        if castPath.isEmpty{
                            //Hack - end loop for now
                            castLoop = 3
                        }
                    }
                }
            }
        }
        
        //snaps held card to position after release
        func snapCard(){
            if (deckOfCards[foundCard].inChain == 1){
                let card = deckOfCards[foundCard]
                let xPos = chainStartXPos + card.inChainAt * 134
                let moveCard = SKAction.move(to: CGPoint(x: xPos, y: 220), duration: 0.1)
                //deckOfCards[chainReferenceArray[i]].position = CGPoint(x: xPos, y:220)
                card.run(moveCard)
                print(fixedChainReferenceArray)
            }
        }
        
        //updates images on all cards according to their deonimator and numerator values
        func updateCardImage(){
            
            for i in 0...(deckOfCards.count - 1){
                
                let card = deckOfCards[i]
                
                //creates and sets label that points to denominator label in view
                let newDenominator : SKLabelNode? = card.childNode(withName: "denominator") as? SKLabelNode
                newDenominator?.text = card.denominator
                
                //creates and sets label that points to numerator label in view
                let newNumerator : SKLabelNode? = card.childNode(withName: "numerator") as? SKLabelNode
                newNumerator?.text = card.numerator
            }
        }
        
        //AUTOMATICALLY UPDATES START
        func updateStart(){
            //let newDenominator : SKLabelNode? = card.childNode(withName: "denominator") as? SKLabelNode
            // newDenominator?.text = card.denominator
            let startCard : SKNode? = self.childNode(withName: "startCard")
            let solutionLabel : SKLabelNode? = startCard?.childNode(withName: "startLabel") as? SKLabelNode
            //if not nill
            if fixedChainReferenceArray[0] != 10{
                let newLabel = deckOfCards[fixedChainReferenceArray[0]].denominator
                solutionLabel?.text = newLabel
            }else{
                solutionLabel?.text = "Start"
            }
        }
        
        //FEEDBACK VALIDITY CHECK
        func createCastPath(){
            
            //only updates start if there is a card in start
            let totalCardsInChain = cardsInChain()
            if  totalCardsInChain > 0{updateStart()}
            
            castPath.append(-1)
            //make path for casting
            for i in stride(from: 0, to: totalCardsInChain, by: 1){
                castPath.append(fixedChainReferenceArray[i])
                castPath.append(20)
                castPath.append(30)
            }
        }
        
        func checkChain(){
            if checkIfValidChain(index: 0){
                let solutionLabel = self.childNode(withName: "feedback") as? SKLabelNode
                solutionLabel?.text = ": )"
            } else{
                let solutionLabel = self.childNode(withName: "feedback") as? SKLabelNode
                solutionLabel?.text = ": ?"
            }
        }
        
        func checkIfValidChain(index: Int) -> Bool{
            
            let totalCardsInChain = cardsInChain()
            let arrayMinusOne = totalCardsInChain - 1
            let indexOfSecond = index + 1
            
            //If not an array of one, and not
            if indexOfSecond < arrayMinusOne {
                
                //current card properties
                let currentCard = deckOfCards[fixedChainReferenceArray[index]]
                
                //next card properties
                let indexOfSecond = index + 1
                let nextCard = deckOfCards[fixedChainReferenceArray[indexOfSecond]]
                
                //current and next card text
                let numeratorOfCurrentCard = currentCard.numerator
                let denominatorOfNextCard = nextCard.denominator
                
                if numeratorOfCurrentCard == denominatorOfNextCard{
                    return checkIfValidChain(index: indexOfSecond)
                } else {return false}
            }
            
            //checking last important card
            if indexOfSecond == arrayMinusOne {
                
                //current card properties
                let currentCard = deckOfCards[fixedChainReferenceArray[index]]
                
                //next card properties
                let indexOfSecond = index + 1
                let nextCard = deckOfCards[fixedChainReferenceArray[indexOfSecond]]
                
                //current and next card text
                let numeratorOfCurrentCard = currentCard.numerator
                let denominatorOfNextCard = nextCard.denominator
                
                if numeratorOfCurrentCard == denominatorOfNextCard{
                    return true
                } else {return false}
            }
            
            //something went wrong
            if totalCardsInChain == 1 {
                return true
            }
            
            //something went wrong
            return false
        }
        
        func cardsInChain()->Int{
            var totalCardsInChain = 0
            for i in stride(from: 0, to: 8, by: 1){
                if fixedChainReferenceArray[i] != 10{
                    totalCardsInChain += 1
                }
            }
            return totalCardsInChain
        }
        
        //UPDATES MOVEMENTS OF CHAINS
        
        //Overall chain update dependent on card
        //Entering chain, moving in chain, and removed from chain
        func updateChain(cardPoint: CGPoint){
            
            let card = deckOfCards[foundCard]
            
            //checks to see if in chain area
            if let newChainArea = self.chainArea{
                
                let cardBack : SKSpriteNode? = card.childNode(withName: "cardBack") as? SKSpriteNode
                
                if let newCardBack = cardBack, (newCardBack.intersects(newChainArea)){
                    
                    //entering chain
                    if (card.inChain==0){
                        chainCount += 1
                        
                        //indicate to card it is in chain
                        print("Enter Chain!")
                        updateChainPositionsEnter()
                    }
                    
                    //card moving in chain
                    if (card.inChain==1){
                        updateChainPositionsMove()
                    }
                    
                }
                    
                    //Removed card from chain condition
                else{
                    if (card.inChain==1){
                        
                        chainCount -= 1
                        card.inChain = 0
                        
                        var removeArrayValueAtIndex = card.inChainAt - 1
                        if removeArrayValueAtIndex < 0{
                            removeArrayValueAtIndex = 0
                        }
                        //set value to empty
                        fixedChainReferenceArray[removeArrayValueAtIndex] = 10
                        
                        card.inChainAt = 0
                        
                        print("Exit Chain")
                        print(fixedChainReferenceArray)
                    }
                }
                updateStart()
            }
        }
        
        //updates card on entrance
        func updateChainPositionsEnter(){
            
            let card = deckOfCards[foundCard]
            
            let maxPosition = (chainStartXPos + 134) + 8 * 134
            
            if Int(card.position.x) < maxPosition {
                
                var cardPlace = Int((card.position.x + 649) / 134)
                if cardPlace > 8{
                    cardPlace = 8
                }
                if cardPlace < 1{
                    cardPlace = 1
                }
                
                let cardPlaceIndex = cardPlace - 1
                print("card place is \(cardPlace)")
                //only enters spots where it is empty
                if fixedChainReferenceArray[cardPlaceIndex] == 10{
                    
                    card.inChain = 1
                    //insert card at place holder
                    let newArrayIndex = cardPlace - 1
                    //set value of fixedChainReferenceArray(place that card is at) to card touched
                    fixedChainReferenceArray[newArrayIndex] = foundCard
                    
                    //update the card location of card
                    card.inChainAt = cardPlace
                }
                    
                    //entering a spot with a card
                else{
                    card.inChain = 1
                    //push where there is the closest space
                    //read right -> return distance to space
                    let rightSpace = findSpace(direction: 1, start: cardPlace)
                    
                    //read left -> return distance to space
                    let leftSpace = findSpace(direction: -1, start: cardPlace)
                    
                    print("Space to right is \(rightSpace), space to left is \(leftSpace)")
                    
                    //lowest distance moves - update position of immediate, then next, repeat until, reach space
                    //As long as both rightSpace and leftSpace don't equal zero
                    
                    
                    //move things right if less than left
                    var lowestDistance = 0
                    var incrementDirection = 0
                    
                    //inserting on far left - go right
                    if leftSpace==0{
                        lowestDistance = rightSpace
                        incrementDirection = -1
                    }
                        //inserting with more space on right (except when right is 0)
                    else if rightSpace != 0, rightSpace < leftSpace{
                        lowestDistance = rightSpace
                        incrementDirection = -1
                    }
                        //go left
                    else{
                        lowestDistance = leftSpace * -1
                        incrementDirection = 1
                    }
                    
                    //WORKING ON LEFT PROBLEM
                    //update all other cards
                    for i in stride(from:lowestDistance, to: 0, by: incrementDirection){
                        //change cardValue for current card and card replacing
                        let cardToBeReplacedIndex = cardPlaceIndex + i - (-1 * incrementDirection)
                        let cardToBeReplaced = deckOfCards[fixedChainReferenceArray[cardToBeReplacedIndex]]
                        
                        let replacedCardPlace = cardPlace + i
                        
                        cardToBeReplaced.inChainAt = replacedCardPlace
                        
                        //Update array
                        let oldArraryCardValue = fixedChainReferenceArray[cardToBeReplacedIndex]
                        
                        let emptySpotIndex = cardPlaceIndex + i
                        
                        fixedChainReferenceArray[emptySpotIndex] = oldArraryCardValue
                    }
                    
                    //update new card last
                    card.inChainAt = cardPlace
                    let indexCardSwitched = cardPlace - 1
                    fixedChainReferenceArray[indexCardSwitched] = foundCard
                    
                    updateChainPositions(movingCardAtIndex: indexCardSwitched)
                    
                    
                    print(fixedChainReferenceArray)
                }
            }
        }
        
        //returns empty space when overlap of cards
        func findSpace(direction: Int, start: Int) -> Int {
            
            //direction of 1 = to right
            //direction of -1 = to left
            
            var numberOfSearches = 0
            
            if direction == 1 {
                numberOfSearches = 8 - start
            } else{ numberOfSearches = 7 - (8 - start)}
            
            print("numberOfSearches is \(numberOfSearches)")
            
            for i in 0...numberOfSearches{
                
                let indexCheck = (start-1) + i * direction
                
                if indexCheck > -1, fixedChainReferenceArray[indexCheck] == 10{
                    return i
                }
            }
            
            //array is full
            return 0
        }
        
        //update card when moving around in chain
        func updateChainPositionsMove(){
            
            let card = deckOfCards[foundCard]
            
            let maxPosition = (chainStartXPos + 134) + 8 * 134
            
            if Int(card.position.x) < maxPosition {
                
                var cardPlace = Int((card.position.x + 649) / 134)
                
                //may be entering from right side
                if cardPlace > 8{
                    cardPlace = 8
                }
                
                //may be entering from left side
                if cardPlace < 1 {
                    cardPlace = 1
                }
                
                //condition if card has moved somewhere outside of it's original place in chain
                if card.inChainAt != cardPlace{
                    
                    //update array
                    let newArrayIndex = cardPlace - 1
                    let oldArrayIndex = card.inChainAt - 1
                    
                    //as long as there is something to replace
                    
                    //update both places in array
                    fixedChainReferenceArray[oldArrayIndex] = fixedChainReferenceArray[newArrayIndex]
                    fixedChainReferenceArray[newArrayIndex] = foundCard
                    
                    //Update old and new inChainAt's
                    let cardToReplace = deckOfCards[fixedChainReferenceArray[newArrayIndex]]
                    //sets cards position to card that will replace
                    cardToReplace.inChainAt = card.inChainAt
                    card.inChainAt = cardPlace
                    
                    print(fixedChainReferenceArray)
                    
                    updateChainPositions(movingCardAtIndex: newArrayIndex)
                }
            }
        }
        
        //update moves card accourding to index of chainReferenceArray
        func updateChainPositions(movingCardAtIndex: Int){
            for i in 0...(fixedChainReferenceArray.count-1){
                if i != movingCardAtIndex{
                    let xPos = chainStartXPos + (i + 1) * 134
                    //move card as long as not nil
                    if fixedChainReferenceArray[i] != 10{
                        deckOfCards[fixedChainReferenceArray[i]].inChainAt = i + 1
                        let moveCard = SKAction.move(to: CGPoint(x: xPos, y: 220), duration: 0.12)
                        //deckOfCards[chainReferenceArray[i]].position = CGPoint(x: xPos, y:220)
                        deckOfCards[fixedChainReferenceArray[i]].run(moveCard)
                    }
                }
            }
        }
        
        func condenseSpellChain(){
            
            var tempArray = [Int]()
            
            for i in stride(from: 0, to: 8, by: 1){
                if fixedChainReferenceArray[i] != 10{
                    tempArray.append(fixedChainReferenceArray[i])
                    let card = deckOfCards[fixedChainReferenceArray[i]]
                    card.inChainAt = i + 1
                }
            }
            
            if tempArray.count < 8 {
                let emptySpacesLeft = 8 - tempArray.count
                for _ in stride(from: 0, to: emptySpacesLeft, by: 1){
                    tempArray.append(10)
                }
            }
            
            //update all cards
            fixedChainReferenceArray = tempArray
            print(fixedChainReferenceArray)
            updateStart()
            updateChainPositions(movingCardAtIndex: 10)
        }
        
        func resetColor(){
            for i in stride(from: 0, to: deckOfCards.count, by: 1){
                let card = deckOfCards[i]
                let solutionLabel : SKLabelNode? = startCard?.childNode(withName: "startLabel") as? SKLabelNode
                solutionLabel?.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let newDenominator : SKLabelNode? = card.childNode(withName: "denominator") as? SKLabelNode
                newDenominator?.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let newNumerator : SKLabelNode? = card.childNode(withName: "numerator") as? SKLabelNode
                newNumerator?.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        
        /*
         //update card when moving around in chain
         func updateChainPositionsMove(){
         
         let card = deckOfCards[foundCard]
         
         let maxPosition = (chainStartXPos + 134) + (chainReferenceArray.count - 1) * 134
         
         if Int(card.position.x) < maxPosition {
         
         let cardPlace = Int((card.position.x + 580) / 134) + 1
         
         //condition if card has moved somewhere outside of it's original place in chain
         if card.inChainAt != cardPlace{
         
         //log shift
         logMutableConversions += 1
         print("Total mutable conversions: \(logMutableConversions)")
         
         //update array
         let newArrayIndex = cardPlace - 1
         let oldArrayIndex = card.inChainAt - 1
         
         //remove old index, insert at new location
         chainReferenceArray.remove(at: oldArrayIndex)
         chainReferenceArray.insert(foundCard, at: newArrayIndex)
         
         //update position value of card and position of other cards
         card.inChainAt = cardPlace
         updateChainPositions(movingCardAtIndex: newArrayIndex)
         }
         }
         }
         
         //updates card on entrance
         func updateChainPositionsEnter(){
         
         let card = deckOfCards[foundCard]
         
         let maxPosition = (chainStartXPos + 134) + chainReferenceArray.count * 134
         
         if Int(card.position.x) < maxPosition {
         
         let cardPlace = Int((card.position.x + 580) / 134) + 1
         
         //insert card at place holder
         let newArrayIndex = cardPlace - 1
         
         //insert foundCard into the array at index of card
         chainReferenceArray.insert(foundCard, at: newArrayIndex)
         
         //update the card location of card
         card.inChainAt = cardPlace
         updateChainPositions(movingCardAtIndex: newArrayIndex)
         
         }else{
         //update card at end (we already know it intersects)
         chainReferenceArray.append(foundCard)
         card.inChainAt = chainReferenceArray.count
         }
         }
         
         //update moves card accourding to index of chainReferenceArray
         func updateChainPositions(movingCardAtIndex: Int){
         
         for i in 0...(chainReferenceArray.count-1){
         if i != movingCardAtIndex{
         let xPos = chainStartXPos + (i + 1) * 134
         deckOfCards[chainReferenceArray[i]].inChainAt = i + 1
         let moveCard = SKAction.move(to: CGPoint(x: xPos, y: 220), duration: 0.12)
         //deckOfCards[chainReferenceArray[i]].position = CGPoint(x: xPos, y:220)
         deckOfCards[chainReferenceArray[i]].run(moveCard)
         }
         }
         }
         */
        //DEBUGGER FUNCITONS -- PRINT ALL CARDS
        func printCards(){
            for i in 0...(chainReferenceArray.count-1){
                let card = deckOfCards[chainReferenceArray[i]]
                print("card i: \(i)")
                print("numerator is: \(card.numerator)")
                print("denominator is: \(card.denominator)")
            }
        }
        
    }
