//
//  SMEpisode.swift
//  soap4me
//
//  Created by Sema Belokovsky on 20/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

enum SMEpisodeTranslateType: Int {
    case Subs = 0
    case Voice = 1
}

enum SMEpisodeQuality: Int {
    case SD = 0
    case HD = 1
}

class SMEpisode: RLMObject {
    
    dynamic var eid: Int = 0
    dynamic var sid: Int = 0
    dynamic var episode: Int = 0
    dynamic var season: Int = 0
    dynamic var quality: Int = SMEpisodeQuality.SD.rawValue
    dynamic var translate_type: Int = SMEpisodeTranslateType.Subs.rawValue
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
                if prop.name == "hsh" {
                    setPropertyForObject(prop, d["hash"], self)
                } else if (prop.name == "quality") {
                    if let value = d["quality"] as? String {
                        switch value {
                        case "SD": self.quality = SMEpisodeQuality.SD.rawValue
                        case "720p": self.quality = SMEpisodeQuality.HD.rawValue
                        default: break
                        }
                    }
                } else if (prop.name == "translate_type") {
                    if let value = d["translate"] as? String {
                        switch value {
                        case " Субтитры": self.translate_type = SMEpisodeTranslateType.Subs.rawValue
                        default: self.translate_type = SMEpisodeTranslateType.Voice.rawValue
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
