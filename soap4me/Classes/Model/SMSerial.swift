//
//  SMSerial.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

public enum SMSerialStatus: Int {
    case Open = 0
    case Ended = 1
    case Closed = 2
}

class SMSerial: RLMObject {
    dynamic var sid: Int = 0
    dynamic var status: Int = 0
    dynamic var watching: Int = 0
    dynamic var unwatched: Int = 0
    
    dynamic var year: Int = 0
    dynamic var imdb_id: String = ""
    dynamic var imdb_rating: Double = 0
    dynamic var imdb_votes: Int = 0
    
    dynamic var tvdb_id: Double = 0
    
    dynamic var title: String = ""
    dynamic var title_ru: String = ""
    dynamic var desc: String = ""
    
    func fillWithDict(dict: [String: AnyObject]?) {
        if let d = dict {
            
            let props = propertyListForClass(SMSerial.self)
            
            for prop in props {
                if prop.name == "desc" {
                    setPropertyForObject(prop, d["description"], self)
                } else {
                    setPropertyForObject(prop, d[prop.name], self)
                }
            }
        }
    }
    
    static func isOrderedBefore(obj1: SMSerial, obj2: SMSerial) -> Bool {
        var result = obj1.title.caseInsensitiveCompare(obj2.title)
        if result == NSComparisonResult.OrderedAscending || result == NSComparisonResult.OrderedSame {
            return true
        } else {
            return false
        }
    }
}
