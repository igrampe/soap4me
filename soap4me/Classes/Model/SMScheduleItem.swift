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
                        var f = NSDateFormatter()
                        f.dateFormat = "dd.MM.yyyy"
                        var date = f.dateFromString(dateStr)
                        value = date?.timeIntervalSince1970
                    }
                    break
                case "episode_number":
                    if let ps = d["episode"] as? String {
                        var ss = ps.substringFromIndex(advance(ps.startIndex, 4))
                        value = ss
                    }
                    break
                case "season_number":
                    if let ps = d["episode"] as? String {
                        var ss = ps.substringFromIndex(advance(ps.startIndex, 1))
                        ss = ss.substringToIndex(advance(ss.startIndex, 2))
                        value = ss
                    }
                    break
                default:
                    value = d[prop.name]
                }
                setPropertyForObject(prop, d[prop.name], self)
            }
        }
    }
}
