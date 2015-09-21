//
//  SMMyScheduleItem.swift
//  soap4me
//
//  Created by Sema Belokovsky on 27/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMMyScheduleItem: RLMObject {
    dynamic var sid: Int = 0
    dynamic var episode_number: Int = 0
    dynamic var season_number: Int = 0
    
    override init() {
        super.init()
    }
    
    init(scheduleItem: SMScheduleItem) {
        super.init()
        self.sid = scheduleItem.sid
        self.episode_number = scheduleItem.episode_number
        self.season_number = scheduleItem.season_number
    }
}
