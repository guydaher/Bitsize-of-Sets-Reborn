//
//  Cards.swift
//  Sets
//
//  Created by Guy Daher on 10/11/15.
//  Copyright © 2015 guydaher. All rights reserved.
//

import Foundation

// ********************
// Declaration of enums
// ********************

enum Feature {
    case ColorFeature
    case ShapeFeature
    case NumberFeature
    case ShadingFeature
}

enum ColorFeature {
    case red
    case blue
    case green
    
    static let allValues = [red, blue, green]
    
    func simpleDescription() -> String {
        switch self {
        case .red:
            return "red"
        case .blue:
            return "blue"
        case .green:
            return "green"
        }
    }
}

enum ShapeFeature {
    case butterfly
    case drop
    case leaf
    
    static let allValues = [butterfly, drop, leaf]
    
    func simpleDescription() -> String {
        switch self {
        case .butterfly:
            return "butterfly"
        case .drop:
            return "drop"
        case .leaf:
            return "leaf"
        }
    }
}

enum NumberFeature : Int {
    case one
    case two
    case three
    
    static let allValues = [one, two, three]
    
    func simpleDescription() -> String {
        switch self {
        case .one:
            return "one"
        case .two:
            return "two"
        case .three:
            return "three"
        }
    }
}

enum ShadingFeature : Int {
    case full
    case hallow
    case homogen
    
    static let allValues = [full, hallow, homogen]
    
    func simpleDescription() -> String {
        switch self {
        case .full:
            return "full"
        case .hallow:
            return "hallow"
        case .homogen:
            return "homogen"
        }
    }
}

class Card
{
    // ******************
    // Instance variables
    // ******************
    
    private var color: ColorFeature
    private var shape: ShapeFeature
    private var number: NumberFeature
    private var shading: ShadingFeature
    internal var isSelected: Bool
    
    // *****************
    // methods and inits
    // *****************
    
    init(cardNamed: String) {
        color = .green
        shape = .leaf
        number = .three
        shading = .full
        isSelected = false
    }
    
    init(color: ColorFeature, shape: ShapeFeature, number: NumberFeature, shading: ShadingFeature) {
        self.color = color
        self.shape = shape
        self.number = number
        self.shading = shading
        self.isSelected = false
    }
    
    func simpleDescription() -> String {
        return "Color: \(color.simpleDescription()), Shape: \(shape.simpleDescription()), Number: \(number.simpleDescription()), Shading: \(shading.simpleDescription())"
    }
    
    func abbreviatedDescription(numberOfCharacters: Int) -> String {
        return "\(shading.simpleDescription().substringWithRange(Range<String.Index>(start: shading.simpleDescription().startIndex, end: shading.simpleDescription().startIndex.advancedBy(numberOfCharacters))))-\(color.simpleDescription().substringWithRange(Range<String.Index>(start: color.simpleDescription().startIndex, end: color.simpleDescription().startIndex.advancedBy(numberOfCharacters))))-\(shape.simpleDescription().substringWithRange(Range<String.Index>(start: shape.simpleDescription().startIndex, end: shape.simpleDescription().startIndex.advancedBy(numberOfCharacters))))-\(number.simpleDescription().substringWithRange(Range<String.Index>(start: number.simpleDescription().startIndex, end: number.simpleDescription().startIndex.advancedBy(numberOfCharacters))))"
    }
    
    static func isSuccessfulSet(setOfThreeCards: SetOfThreeCards) -> Bool {
        
        let colorCheck = isFeatureChecked(.ColorFeature, card1: setOfThreeCards.firstCard, card2: setOfThreeCards.secondCard, card3: setOfThreeCards.thirdCard)
        let shapeCheck = isFeatureChecked(.ShapeFeature, card1: setOfThreeCards.firstCard, card2: setOfThreeCards.secondCard, card3: setOfThreeCards.thirdCard)
        let numberCheck = isFeatureChecked(.NumberFeature, card1: setOfThreeCards.firstCard, card2: setOfThreeCards.secondCard, card3: setOfThreeCards.thirdCard)
        let shadingCheck = isFeatureChecked(.ShadingFeature, card1: setOfThreeCards.firstCard, card2: setOfThreeCards.secondCard, card3: setOfThreeCards.thirdCard)
        
        return colorCheck && shapeCheck && numberCheck && shadingCheck
    }
    
    
    static private func isFeatureChecked(feature: Feature, card1: Card, card2: Card, card3: Card) -> Bool {
        return isSameFeature(feature, card1: card1, card2: card2, card3: card3) || isDifferentFeature(feature, card1: card1, card2: card2, card3: card3)
    }
    
    static private func isSameFeature(feature: Feature, card1: Card, card2: Card, card3: Card) -> Bool {
        switch feature {
        case .ColorFeature: return card1.color == card2.color && card2.color == card3.color
        case .ShapeFeature: return card1.shape == card2.shape && card2.shape == card3.shape
        case .NumberFeature: return card1.number == card2.number && card2.number == card3.number
        case .ShadingFeature: return card1.shading == card2.shading && card2.shading == card3.shading
        }
    }
    
    static private func isDifferentFeature(feature: Feature, card1: Card, card2: Card, card3: Card) -> Bool {
        switch feature {
        case .ColorFeature: return card1.color != card2.color && card2.color != card3.color && card3.color != card1.color
        case .ShapeFeature: return card1.shape != card2.shape && card2.shape != card3.shape && card3.shape != card1.shape
        case .NumberFeature: return card1.number != card2.number && card2.number != card3.number && card3.number != card1.number
        case .ShadingFeature: return card1.shading != card2.shading && card2.shading != card3.shading && card3.shading != card1.shading
        }
    }
}
