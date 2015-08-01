//
//  SMSeason.swift
//  soap4me
//
//  Created by Sema Belokovsky on 22/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMSeason: RLMObject {
    dynamic var sid: Int = 0
    dynamic var season_number: Int = 0
    dynamic var season_id: Int = 0
    dynamic var unwatched: Int = 0
    
    static func isOrderedBeforeAsc(obj1: SMSeason, obj2: SMSeason) -> Bool {
        var result = obj1.season_number < obj2.season_number
        return result
    }
    
    static func isOrderedBeforeDesc(obj1: SMSeason, obj2: SMSeason) -> Bool {
        var result = obj1.season_number > obj2.season_number
        return result
    }
}

