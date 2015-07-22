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

enum SMEpisodeQualityMask: Int {
    case None   = 0b00
    case SD     = 0b01
    case HD     = 0b10
}

enum SMEpisodeTranslationMask: Int {
    case None   = 0b00
    case Subs   = 0b01
    case Voice  = 0b10
}

class SMMetaEpisode: RLMObject {
    dynamic var sid: Int = 0
    dynamic var season_id: Int = 0
    dynamic var season: Int = 0
    dynamic var episode: Int = 0
    dynamic var title_ru: String = ""
    dynamic var title_en: String = ""
    dynamic var watched: Bool = false
    dynamic var qualityMask: Int = SMEpisodeQualityMask.None.rawValue
    dynamic var translationMask: Int = SMEpisodeTranslationMask.None.rawValue
    
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
            self.translationMask = self.translationMask|SMEpisodeTranslationMask.Subs.rawValue
        } else if episode.translate_type == SMEpisodeTranslateType.Voice.rawValue {
            self.translationMask = self.translationMask|SMEpisodeTranslationMask.Voice.rawValue
        }
        
        if episode.quality == SMEpisodeQuality.SD.rawValue {
            self.qualityMask = self.qualityMask|SMEpisodeQualityMask.SD.rawValue
        } else if episode.quality == SMEpisodeQuality.HD.rawValue {
            self.qualityMask = self.qualityMask|SMEpisodeQualityMask.HD.rawValue
        }
        
        self.episodes.addObject(episode)
    }
}
