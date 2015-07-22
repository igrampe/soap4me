//
//  SMMetaEpisode.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SMMetaEpisode: RLMObject {
    dynamic var sid: Int = 0
    dynamic var season_id: Int = 0
    dynamic var season: Int = 0
    dynamic var episode: Int = 0
    dynamic var title_ru: String = ""
    dynamic var title_en: String = ""
    dynamic var watched: Bool = false
    
    dynamic var hasHD: Bool = false
    dynamic var hasSD: Bool = false
    
    dynamic var hasSub: Bool = false
    dynamic var hasVoice: Bool = false
    
    dynamic var episodes = RLMArray(objectClassName: "SMEpisode")
    
    func appendEpisode(episode: SMEpisode) {
        self.sid = episode.sid
        self.season_id = episode.season_id
        self.season = episode.season
        self.episode = episode.episode
        self.title_en = episode.title_en
        self.title_ru = episode.title_ru
        self.watched = episode.watched
        
        if episode.translate_type == SMEpisodeTranslateType.Subs.rawValue {
            self.hasSub = true
        } else if episode.translate_type == SMEpisodeTranslateType.Voice.rawValue {
            self.hasVoice = true
        }
        
        if episode.quality == SMEpisodeQuality.SD.rawValue {
            self.hasSD = true
        } else if episode.quality == SMEpisodeQuality.HD.rawValue {
            self.hasHD = true
        }
        
        self.episodes.addObject(episode)
    }
}
