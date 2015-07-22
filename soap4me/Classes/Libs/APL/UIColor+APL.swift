//
//  UIColor+APL.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var (r, g, b, a) = UIColor.colorComponentsWithString(hex)
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    static func colorWithString(string: String) -> UIColor {
        
        var lcs = string.lowercaseString
        
        lcs = lcs.stringByReplacingOccurrencesOfString("#", withString: "")
        lcs = lcs.stringByReplacingOccurrencesOfString("0x", withString: "")
        
        switch lcs.length() {
            case 0:
                lcs = "00000000"
            case 3:
                var range = Range<String.Index>(start: advance(lcs.startIndex, 0), end: advance(lcs.startIndex, 1))
                let r = lcs.substringWithRange(range)
                range = Range<String.Index>(start: advance(lcs.startIndex, 1), end: advance(lcs.startIndex, 2))
                let g = lcs.substringWithRange(range)
                range = Range<String.Index>(start: advance(lcs.startIndex, 2), end: advance(lcs.startIndex, 3))
                let b = lcs.substringWithRange(range)
                lcs = "\(r)\(r)\(g)\(g)\(b)\(b)ff"
            case 6:
                lcs = lcs.stringByAppendingString("ff")
            default:
                break
        }
        
        var color: UIColor
        
        var rgba = UInt32()
        let scanner: NSScanner = NSScanner(string: lcs)
        scanner.scanHexInt(&rgba)

        color =  self.colorWithRGBAValue(rgba)
        
        return color
    }
    
    static func colorComponentsWithString(string: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var lcs = string.lowercaseString
        
        lcs = lcs.stringByReplacingOccurrencesOfString("#", withString: "")
        lcs = lcs.stringByReplacingOccurrencesOfString("0x", withString: "")
        
        switch lcs.length() {
        case 0:
            lcs = "00000000"
        case 3:
            var range = Range<String.Index>(start: advance(lcs.startIndex, 0), end: advance(lcs.startIndex, 1))
            let r = lcs.substringWithRange(range)
            range = Range<String.Index>(start: advance(lcs.startIndex, 1), end: advance(lcs.startIndex, 2))
            let g = lcs.substringWithRange(range)
            range = Range<String.Index>(start: advance(lcs.startIndex, 2), end: advance(lcs.startIndex, 3))
            let b = lcs.substringWithRange(range)
            lcs = "\(r)\(r)\(g)\(g)\(b)\(b)ff"
        case 6:
            lcs = lcs.stringByAppendingString("ff")
        default:
            break
        }
        
        var rgba = UInt32()
        let scanner: NSScanner = NSScanner(string: lcs)
        scanner.scanHexInt(&rgba)
        
        return self.colorComponentsWithRGBAValue(rgba)
    }
    
    static func colorWithRGBAValue(rgba: UInt32) -> UIColor {
        let red: CGFloat = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green: CGFloat = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
        let blue: CGFloat = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
        let alpha: CGFloat = CGFloat(rgba & 0x000000FF) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    static func colorComponentsWithRGBAValue(rgba: UInt32) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let red: CGFloat = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green: CGFloat = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
        let blue: CGFloat = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
        let alpha: CGFloat = CGFloat(rgba & 0x000000FF) / 255.0
        return (red, green, blue, alpha)
    }
}