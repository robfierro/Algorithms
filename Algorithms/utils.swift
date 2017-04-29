//
//  utils.swift
//  Algorithms
//
//  Created by Roberto Fierro Martinez on 4/25/17.
//  Copyright © 2017 Roberto Fierro Martinez. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Generics

struct Stack<Element> {
    fileprivate var array: [Element] = []
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var count: Int {
        return array.count
    }
    
    var description: String {
        
        let topDivider = "---Stack---\n"
        let bottomDivider = "\n-----------\n"
        let stackElements = array.map { "\($0)" }.reversed().joined(separator: "\n")

        return topDivider + stackElements + bottomDivider
    }
    
    mutating func push(_ element: Element) {
        array.append(element)
    }
    
    mutating func pop() -> Element? {
        return array.popLast()
    }
    
    func peek() -> Element? {
        return array.last
    }
}

// MARK: - Foundation Utils

extension Int {
    @nonobjc static var generatedNumbers:[UInt32] = Array()

    static func randomNonRepeatingNumber(seed:Int, clean:Int = 0) -> Int {
        
        if(Int.generatedNumbers.count == clean) {
            Int.generatedNumbers.removeAll()
        }
        
        var randomNumber = arc4random_uniform(UInt32(seed))
        
        while Int.generatedNumbers.contains(randomNumber) {
            randomNumber = arc4random_uniform(UInt32(seed))
        }
        Int.generatedNumbers.append(randomNumber)
        return Int(randomNumber)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


// MARK: - UIKit Utils

extension UIColor {
    
    @nonobjc static var generatedColors:[UIColor] = Array()
    
    static func randomNonRepetingColor(clean:Int = 0) -> UIColor {
        
        if(UIColor.generatedColors.count == clean) {
            UIColor.generatedColors.removeAll()
        }
        
        var color:UIColor = .random()
        
        while UIColor.generatedColors.contains(color) {
            color = .random()
        }
        UIColor.generatedColors.append(color)
        return color
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
    
    func blackOrWhiteContrastingColor() -> UIColor {
        
        let blackDiff = self.luminosityDifference(otherColor: .black)
        let whiteDiff = self.luminosityDifference(otherColor: .white)
        
        return (blackDiff > whiteDiff) ? .black : .white;
    }
    
    func luminosity() -> CGFloat {
        
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            
            return 0.2126 * pow(red, 2.2) + 0.7152 * pow(green, 2.2) + 0.0722 * pow(blue, 2.2)
        }
        
        var white: CGFloat = 0
        
        if self.getWhite(&white, alpha: &alpha) {
            
            return pow(white, 2.2);
        }
        
        return -1
    }
    
    func luminosityDifference(otherColor: UIColor) -> CGFloat {
        let l1 = self.luminosity()
        let l2 = otherColor.luminosity()
        
        if (l1 >= 0 && l2 >= 0) {
            if (l1 > l2) {
                return (l1+0.05) / (l2+0.05);
            } else {
                return (l2+0.05) / (l1+0.05);
            }
        }
        
        return 0.0;
    }
    
}

extension UILabel {

    func textToInt() -> Int {
        
        if let integer = Int(self.text!) {
            return integer
        }
        return 0
    }
}

extension NSLayoutConstraint {
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

@IBDesignable class BottomAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName: font],
                                                                    context: nil).size
            let y = (self.frame.size.height - ceil(labelStringSize.height))
            super.drawText(in: CGRect(x:0,y:y, width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
