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
    case open = 0
    case ended = 1
    case closed = 2
}

class SMSerial: RLMObject {
    var sid: Int = 0
    var status: Int = 0
    var watching: Int = 0
    var unwatched: Int = 0
    
    var year: Int = 0
    var imdb_id: String = ""
    var imdb_rating: Int = 0
    var imdb_votes: Int = 0
    
    var tvdb_id: Double = 0
    
    var title: String = ""
    var title_ru: String = ""
    var desc: String = ""
    
    var my: Bool = false
    
    override init() {
        super.init()
    }
    
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
}
