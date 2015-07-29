//
//  SMSerialScheduleItem.swift
//  soap4me
//
//  Created by Sema Belokovsky on 29/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMSerialScheduleItem: SMScheduleItem {
    class func serialIsOrderedBefore(obj1: SMSerialScheduleItem, obj2: SMSerialScheduleItem) -> Bool {
        return obj1.date > obj2.date
    }
}