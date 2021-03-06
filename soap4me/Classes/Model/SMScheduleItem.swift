//
//  SMScheduleItem.swift
//  soap4me
//
//  Created by Sema Belokovsky on 27/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMScheduleItem: RLMObject {
    dynamic var sid: Int = 0
    dynamic var date: Double = 0
    dynamic var episode_number: Int = 0
    dynamic var season_number: Int = 0
    dynamic var title: String = ""
    dynamic var serial_name: String = ""
    
    func fillWithDict(dict: [String: AnyObject]?) {
        if let d = dict {
            
            let props = propertyListForClass(SMScheduleItem.self)
            
            for prop in props {
                var value: AnyObject?
                
                switch prop.name {
                case "date":
                    if let dateStr = d["date"] as? String {
                        let f = NSDateFormatter()
                        f.dateFormat = "dd.MM.yyyy"
                        let date = f.dateFromString(dateStr)
                        value = date?.timeIntervalSince1970
                    }
                    break
                case "episode_number":
                    if let ps = d["episode"] as? String {
                        let ss = ps.substringFromIndex(ps.startIndex.advancedBy(4))
                        value = ss
                    }
                    break
                case "season_number":
                    if let ps = d["episode"] as? String {
                        var ss = ps.substringFromIndex(ps.startIndex.advancedBy(1))
                        ss = ss.substringToIndex(ss.startIndex.advancedBy(2))
                        value = ss
                    }
                    break
                case "serial_name":
                    value = d["soap"]
                default:
                    value = d[prop.name]
                }
                setPropertyForObject(prop, value: value, object: self)
            }
        }
    }
    
    class func isOrderedBefore(obj1: SMScheduleItem, obj2: SMScheduleItem) -> Bool {
        return obj1.date < obj2.date
    }
}
