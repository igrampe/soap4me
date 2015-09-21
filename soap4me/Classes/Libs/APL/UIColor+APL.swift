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
                var range = Range<String.Index>(start: lcs.startIndex.advancedBy(0), end: lcs.startIndex.advancedBy(1))
                let r = lcs.substringWithRange(range)
                range = Range<String.Index>(start: lcs.startIndex.advancedBy(1), end: lcs.startIndex.advancedBy(2))
                let g = lcs.substringWithRange(range)
                range = Range<String.Index>(start: lcs.startIndex.advancedBy(2), end: lcs.startIndex.advancedBy(3))
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
    
    func hexValue() -> NSString {
        let cn = CGColorGetNumberOfComponents(self.CGColor);
        var r:CGFloat = 0.0
        var g:CGFloat = 0.0
        var b:CGFloat = 0.0
        var a:CGFloat = 0.0
        
        let comps = CGColorGetComponents(self.CGColor)
        
        if cn == 4 {
            r = comps[0];
            g = comps[1];
            b = comps[2];
            a = comps[3];
        } else {
            r = comps[0];
            g = comps[0];
            b = comps[0];
            a = comps[1];
        }
        let hex = String(format: "%02x%02x%02x%02x", Int(r*255), Int(g*255), Int(b*255), Int(a*255))
        return hex
    }
    
    static func colorComponentsWithString(string: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var lcs = string.lowercaseString
        
        lcs = lcs.stringByReplacingOccurrencesOfString("#", withString: "")
        lcs = lcs.stringByReplacingOccurrencesOfString("0x", withString: "")
        
        switch lcs.length() {
        case 0:
            lcs = "00000000"
        case 3:
            var range = Range<String.Index>(start: lcs.startIndex.advancedBy(0), end: lcs.startIndex.advancedBy(1))
            let r = lcs.substringWithRange(range)
            range = Range<String.Index>(start: lcs.startIndex.advancedBy(1), end: lcs.startIndex.advancedBy(2))
            let g = lcs.substringWithRange(range)
            range = Range<String.Index>(start: lcs.startIndex.advancedBy(2), end: lcs.startIndex.advancedBy(3))
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