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
    dynamic var likes: Int = 0
    
    dynamic var tvdb_id: Double = 0
    
    dynamic var kinopoisk_id: Double = 0
    dynamic var kinopoisk_rating: Double = 0
    dynamic var kinopoisk_votes: Double = 0
    
    dynamic var title: String = ""
    dynamic var title_ru: String = ""
    dynamic var desc: String = ""
    
    func fillWithDict(dict: [String: AnyObject]?) {
        if let d = dict {
            
            let props = propertyListForClass(SMSerial.self)
            
            for prop in props {
                if prop.name == "desc" {
                    setPropertyForObject(prop, value: d["description"], object: self)
                } else if prop.name == "unwatched" {
                    if let o:AnyObject = d[prop.name] {
                        if let v = o as? Int {
                            setPropertyForObject(prop, value: v, object: self)
                        } else {
                            self.unwatched = 0
                        }
                    }
                } else {
                    setPropertyForObject(prop, value: d[prop.name], object: self)
                }
            }
        }
    }
    
    static func isOrderedBefore(obj1: SMSerial, obj2: SMSerial) -> Bool {
        let result = obj1.title.caseInsensitiveCompare(obj2.title)
        if result == NSComparisonResult.OrderedAscending || result == NSComparisonResult.OrderedSame {
            return true
        } else {
            return false
        }
    }
}
