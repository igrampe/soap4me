//
//  NSObject+APL.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import Foundation

func intFromObject(object: AnyObject?) -> Int? {
    var result: Int?
    if let v = object as? NSString {
        result = v.integerValue
    } else if let v = object as? Int {
        result = v
    } else if let v = object as? Double {
        result = Int(v)
    }
    return result
}

func doubleFromObject(object: AnyObject?) -> Double? {
    var result: Double?
    if let v = object as? NSString {
        result = v.doubleValue
    } else if let v = object as? Int {
        result = Double(v)
    } else if let v = object as? Double {
        result = v
    }
    return result
}

func boolFromObject(object: AnyObject?) -> Bool? {
    var result: Bool?
    if let v = object as? NSString {
        result = v.boolValue
    } else if let v = object as? Int {
        result = Bool(v)
    } else if let v = object as? Double {
        result = Bool(v)
    } else if let v = object as? Bool {
        result = v
    }
    return result
}

func stringFromObject(object: AnyObject?) -> String? {
    var result: String?
    if let v = object as? String {
        result = v
    } else if let v = object as? Int {
        result = "\(v)"
    } else if let v = object as? Double {
        result = "\(v)"
    }
    return result
}

func setPropertyForObject(objectProperty: ObjectProperty, value: AnyObject?, object: NSObject) {
    if (objectProperty.type == "q") {
        if let v = intFromObject(value) {
            object.setValue(v, forKey: objectProperty.name)
        }
    } else if (objectProperty.type == "l") {
        if let v = intFromObject(value) {
            object.setValue(v, forKey: objectProperty.name)
        }
    } else if (objectProperty.type == "d") {
        if let v = doubleFromObject(value) {
            object.setValue(v, forKey: objectProperty.name)
        }
    } else if (objectProperty.type == "@") {
        if let v = stringFromObject(value) {
            object.setValue(v, forKey: objectProperty.name)
        }
    } else if (objectProperty.type == "B") {
        if let v = boolFromObject(value) {
            object.setValue(v, forKey: objectProperty.name)
        }
    }
}

struct ObjectProperty {
    var name: String
    var attributes: [String]
    var type: String
}

func propertyListForClass(cls: AnyClass!) -> [ObjectProperty] {
    var propertyList : [ObjectProperty] = []
    
    if let classToInspect:AnyClass = cls {
        var count : UInt32 = 0
        let properties : UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(classToInspect, &count)
        
        let intCount = Int(count)
        for var i = 0; i < intCount; i++ {
            let property : objc_property_t = properties[i]
            let propertyName = String(UTF8String: property_getName(property))!
            let propertyAttrs = (String(UTF8String: property_getAttributes(property))!).componentsSeparatedByString(",")
            var type: String = "u"
            for a:String in propertyAttrs {
                if a.hasPrefix("T") {
                    let range = Range<String.Index>(start: advance(a.startIndex, 1), end: a.endIndex)
                    type = a.substringWithRange(range)
//                    type = type.stringByReplacingOccurrencesOfString("@", withString: "")
//                    type = type.stringByReplacingOccurrencesOfString("\\", withString: "")
//                    type = type.stringByReplacingOccurrencesOfString("\"", withString: "")
                }
            }
            let objectProperty = ObjectProperty(name: propertyName, attributes: propertyAttrs, type: type)
            propertyList.append(objectProperty)
        }
        free(properties)
    }
    
    return propertyList
}