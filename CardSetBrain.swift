//
//  CardBrain.swift
//  Sets
//
//  Created by Guy Daher on 10/31/15.
//  Copyright © 2015 guydaher. All rights reserved.
//

import Foundation

public class CardSetBrain {
    
    // *********
    // variables
    // *********
    
    private var cardsOnScreen = [Int:Card]() // the 12 cards from tag = 1 to tag = 12
    private var allCards = Stack<Card>(element: []) // all 81 cards
    private var numberOfCardsSelected = 0
    var gameMode: GameMode
    
    let TOTAL_NUMBER_OF_CARDS_ON_SCREEN = 12
    let NUMBER_OF_CARDS_DEBUG = 81
    
    // *****************
    // methods and inits
    // *****************
    
    // MARK: Deck Card Creation
    
    init(gameMode: GameMode) {
        self.gameMode = gameMode
        
        repeat {
            allCards = createDeckOfSetCards()
            print("Number of cards in deck: \(allCards.items.count)")
            print("Game Mode is \(gameMode.simpleDescription())")
            distributeInitialTwelveCards()
        } while cannotFindSetOnScreen()
    }
    
    private func distributeInitialTwelveCards() {
        for index in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
            let card = allCards.pop()
            cardsOnScreen[index] = card
        }
    }
    
    private func createDeckOfSetCards() -> Stack<Card> {
        var cards: [Card]
        var shuffledCards: [Card]
        switch (self.gameMode) {
        case .ClassicSet81:
            cards = initializeDeckOfSetCards()
            shuffledCards = cards.shuffle()
        case .ClassicSet54:
            cards = initializeDeckOfSetCards()
            let shuffledAllCards = cards.shuffle()
            shuffledCards = Array(shuffledAllCards[0..<54])
        case .ClassicSet27:
            cards = initializeDeckOfSetCards()
            let shuffledAllCards = cards.shuffle()
            shuffledCards = Array(shuffledAllCards[0..<27])
        case .EasySet:
            cards = initializeEasyDeckOfSetCards()
            shuffledCards = cards.shuffle()
        case .TimerSet1, .TimerSet3, .TimerSet5:
            cards = initializeDeckOfSetCards()
            shuffledCards = cards.shuffle()
        }
        
        return Stack<Card>(element: shuffledCards)
    }
    
    private func initializeDeckOfSetCards() -> [Card] {
        var cards = [Card]()
        
        for color in ColorFeature.allValues {
            for shape in ShapeFeature.allValues {
                for number in NumberFeature.allValues {
                    for shading in ShadingFeature.allValues {
                        cards.append(Card(color: color, shape: shape, number: number, shading: shading))
                        #if DEBUG
                            if cards.count == NUMBER_OF_CARDS_DEBUG {
                                return cards
                            }
                        #endif
                    }
                }
            }
        }
        
        return cards
    }
    
    private func initializeEasyDeckOfSetCards() -> [Card] {
        var cards = [Card]()
        
        for shape in ShapeFeature.allValues {
            for number in NumberFeature.allValues {
                for shading in ShadingFeature.allValues {
                    cards.append(Card(color: ColorFeature.blue, shape: shape, number: number, shading: shading))
                    #if DEBUG
                        if cards.count == NUMBER_OF_CARDS_DEBUG {
                            return cards
                        }
                    #endif
                }
            }
        }
        
        
        return cards
    }
    
    // MARK: Methods for the ViewController to request state info from the CardSetBrain
    
    func titleOfButton(cardNumber: Int) -> String {
        return cardsOnScreen[cardNumber]?.abbreviatedDescription(2) ?? ""
    }
    
    func isCardEmptyForId(id: Int) -> Bool {
        return cardsOnScreen[id] == nil
    }
    
    func isScreenFilledWithCards() -> Bool {
        return cardsOnScreen[TOTAL_NUMBER_OF_CARDS_ON_SCREEN - 1] != nil
    }
    
    func isSetAvailableWithThisCard(potentialCard: Card, cardsLeftOnScreen: [Int:Card]) -> Bool{
        var potentialThreeCards: SetOfThreeCards
        for index in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
            for index2 in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
                if (cardsLeftOnScreen[index] != nil && cardsLeftOnScreen[index2] != nil) {
                    if (index != index2) {
                        potentialThreeCards = SetOfThreeCards(firstCard: cardsLeftOnScreen[index]!, secondCard: cardsLeftOnScreen[index2]!, thirdCard: potentialCard)
                        if (Card.isSuccessfulSet(potentialThreeCards)) {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func cannotFindSetOnScreen() -> Bool {
        return findSetOnScreen() == nil
    }
    
    func canFindSetOnScreen() -> Bool {
        return findSetOnScreen() != nil
    }
    
    func isRoundComplete() -> Bool {
        return cardsOnScreen.isEmpty || cannotFindSetOnScreen()
    }
    
    func getThreeSelectedIds() -> [Int]? {
        let threeSelectedIds = cardsOnScreen.filter{(index, cardOnScreen) in cardOnScreen.isSelected}.map{(index, cardOnScreen) in index}
        
        if (threeSelectedIds.count == 3) {
            return threeSelectedIds
        }
        
        return nil
    }
    
    func findSetOnScreen() -> [Int]?{
        var potentialThreeCards: SetOfThreeCards
        for index in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
            for index2 in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
                for index3 in 1...TOTAL_NUMBER_OF_CARDS_ON_SCREEN {
                    if (cardsOnScreen[index] != nil && cardsOnScreen[index2] != nil && cardsOnScreen[index3] != nil) {
                        if (index != index2 && index2 != index3 && index3 != index) {
                            potentialThreeCards = SetOfThreeCards(firstCard: cardsOnScreen[index]!, secondCard: cardsOnScreen[index2]!, thirdCard: cardsOnScreen[index3]!)
                            if (Card.isSuccessfulSet(potentialThreeCards)) {
                                return [index, index2, index3]
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func getThreeSelectedCards() -> SetOfThreeCards? {
        var threeSelectedCards = cardsOnScreen.filter{(index, cardOnScreen) in cardOnScreen.isSelected}.map{$1}
        
        if (threeSelectedCards.count == 3) {
            return SetOfThreeCards(firstCard: threeSelectedCards[0], secondCard: threeSelectedCards[1], thirdCard: threeSelectedCards[2])
        }
        
        return nil
    }
    
    // MARK: Methods for the ViewController to do some action on the CardSetBrain

    func HandleCardClicked(cardNumber: Int) -> CardViewsState? {
        if cardsOnScreen[cardNumber] != nil {
            if (!cardsOnScreen[cardNumber]!.isSelected) {
                cardsOnScreen[cardNumber]!.isSelected = true
                numberOfCardsSelected++
                
                if (numberOfCardsSelected == 3) {
                    numberOfCardsSelected = 0
                    return resolveSet()
                } else {
                    return .SelectCurrent
                }
            } else {
                cardsOnScreen[cardNumber]!.isSelected = false
                numberOfCardsSelected--
                return .UnSelectCurrent
            }
        }
        
        return nil
    }
    
    private func resolveSet() -> CardViewsState? {
        if let setOfThreeCards = getThreeSelectedCards() {
            if (Card.isSuccessfulSet(setOfThreeCards)) {
                return .CorrectSet
            } else {
                return .IncorrectSet
            }
        }
        return nil
    }

    func exchangeCards(id1: Int, id2: Int) {
        let tempCard = cardsOnScreen[id1]
        cardsOnScreen[id1] = cardsOnScreen[id2]
        cardsOnScreen[id2] = tempCard
    }
    
    func unSelectAllCards() {
        for (_, cardOnScreen) in cardsOnScreen {
            cardOnScreen.isSelected = false
        }
    }
    
    func unSelectCardWithId(id: Int) {
        cardsOnScreen[id]?.isSelected = false
    }

    func replaceCardWithId(cardId: Int) -> Bool {
        if allCards.items.count > 0 {
            // TODO Here we're loosing track of sets that were found. might want to store them somewhere to show on "victory screen"
            cardsOnScreen[cardId] = allCards.pop()
            return true
        }
        
        cardsOnScreen[cardId] = nil
        return false
    }
    
}

struct SetOfThreeCards {
    var firstCard: Card
    var secondCard: Card
    var thirdCard: Card
}

enum CardViewsState {
    case SelectCurrent
    case UnSelectCurrent
    case CorrectSet
    case IncorrectSet
}