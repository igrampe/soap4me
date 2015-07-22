//
//  SMEpisode.swift
//  soap4me
//
//  Created by Sema Belokovsky on 20/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMEpisode: RLMObject {
    
    dynamic var eid: Int = 0
    dynamic var sid: Int = 0
    dynamic var episode: Int = 0
    dynamic var season: Int = 0
    dynamic var quality: Int = 0
    dynamic var translate_type: Int = 0
    dynamic var translate: String = ""
    dynamic var hsh: String = ""
    dynamic var title_en: String = ""
    dynamic var title_ru: String = ""
    dynamic var spoiler: String = ""
    dynamic var season_id: Int = 0
    dynamic var watched: Bool = false
    
    func fillWithDict(dict: [String: AnyObject]?) {
        if let d = dict {
            let props = propertyListForClass(SMEpisode.self)
            for prop in props {
                if prop.name == "hash" {
                    setPropertyForObject(prop, d["hsh"], self)
                } else if (prop.name == "quality") {
                    if let value = d["quality"] as? String {
                        switch value {
                        case "SD": self.quality = 0
                        case "720p": self.quality = 1
                        default: break
                        }
                    }
                } else if (prop.name == "translate_type") {
                    if let value = d["translate"] as? String {
                        switch value {
                        case " Субтитры": self.translate_type = 0
                        default: self.translate_type = 1
                        }
                    }
                } else {
                    setPropertyForObject(prop, d[prop.name], self)
                }
            }
            if self.translate.hasPrefix(" ") {
                self.translate.substringFromIndex(advance(self.translate.startIndex, 1))
            }
        }
    }
}
