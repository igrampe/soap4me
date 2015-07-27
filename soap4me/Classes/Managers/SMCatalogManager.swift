//
//  SMCatalogManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

let DB_VERSION = 1
let SCHEMA_VERSION: UInt64 = 1

enum SMCatalogManagerNotification: String {
    case ApiGetSerialsMySucceed = "ApiGetSerialsMySucceed"
    case ApiGetSerialsMyFailed = "ApiGetSerialsMyFailed"
    
    case ApiGetSerialsAllSucceed = "ApiGetSerialsAllSucceed"
    case ApiGetSerialsAllFailed = "ApiGetSerialsAllFailed"
    
    case ApiGetSerialMetaSucceed = "ApiGetSerialMetaSucceed"
    case ApiGetSerialMetaFailed = "ApiGetSerialMetaFailed"
    
    case ApiGetEpisodesSucceed = "ApiGetEpisodesSucceed"
    case ApiGetEpisodesFailed = "ApiGetEpisodesFailed"
    
    case ApiSerialToggleWatchingSucceed = "ApiSerialToggleWatchingSucceed"
    case ApiSerialToggleWatchingFailed = "ApiSerialToggleWatchingFailed"
    
    case ApiEpisodeToggleWatchedSucceed = "ApiEpisodeToggleWatchedSucceed"
    case ApiEpisodeToggleWatchedFailed = "ApiEpisodeToggleWatchedFailed"
    
    case ApiEpisodeGetLinkInfoSucceed = "ApiEpisodeGetLinkInfoSucceed"
    case ApiEpisodeGetLinkInfoFailed = "ApiEpisodeGetLinkInfoFailed"
    
    case ApiGetScheduleSucceed = "ApiGetScheduleSucceed"
    case ApiGetScheduleFailed = "ApiGetScheduleFailed"
}

class SMCatalogManager: NSObject {
    
    static let sharedInstance = SMCatalogManager()
    
    private var _realm: RLMRealm?
    
    private func realm() -> RLMRealm {
        if _realm == nil {
//            var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
//            path = path.stringByAppendingPathComponent("db_\(DB_VERSION).realm")
            
            RLMRealm.setDefaultRealmSchemaVersion(SCHEMA_VERSION, withMigrationBlock: { (migration, oldSchemaVersion) -> Void in
                
                })
            
//            RLMRealm.setSchemaVersion(SCHEMA_VERSION, forRealmAtPath: path, withMigrationBlock: { (migration, oldSchemaVersion) -> Void in
//                
//            })
            
            _realm = RLMRealm.defaultRealm()
        }
        
        return _realm!
    }
    
    func clearState() {
        self.realm().beginWriteTransaction()
        
        var results = SMMySerial.allObjectsInRealm(self.realm())
        self.realm().deleteObjects(results)
        
        results = SMMetaEpisode.allObjectsInRealm(self.realm())
        self.realm().deleteObjects(results)
        
        results = SMEpisode.allObjectsInRealm(self.realm())
        self.realm().deleteObjects(results)
        
        results = SMMySerial.allObjectsInRealm(self.realm())
        self.realm().deleteObjects(results)
        
        self.realm().commitWriteTransaction()
    }
    
    //MARK: DB
    
    //MARK: -Serials
    
    private func getSerialsWithPredicate(predicate: NSPredicate?) -> [SMSerial] {
        var results: RLMResults
        if let p = predicate {
            results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
        } else {
            results = SMSerial.allObjectsInRealm(self.realm())
        }
        var objects = [SMSerial]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMSerial = results.objectAtIndex(i) as! SMSerial
            objects.append(object)
        }
        return objects
    }
    
    private func getMySerialsSids() -> [Int] {
        var results = SMMySerial.allObjectsInRealm(self.realm())
        var sids = [Int]()
        for var i:UInt = 0; i < results.count; i++ {
            var ms: SMMySerial = results.objectAtIndex(i) as! SMMySerial
            sids.append(ms.sid)
        }
        return sids
    }
    
    func getSerialsMyUnwatched() -> [SMSerial]  {
        var sids = self.getMySerialsSids()
        var p = NSPredicate(format: "unwatched > 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyWatched() -> [SMSerial]  {
        var sids = self.getMySerialsSids()
        var p = NSPredicate(format: "unwatched == 0 and status == 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyEnded() -> [SMSerial]  {
        var sids = self.getMySerialsSids()
        var p = NSPredicate(format: "unwatched == 0 and status != 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsAll() -> [SMSerial] {
        return self.getSerialsWithPredicate(nil)
    }
    
    func getSerialWithSid(sid: Int) -> SMSerial? {
        var p = NSPredicate(format: "sid == %d", sid)
        var serials = self.getSerialsWithPredicate(p)
        return serials.first
    }
    
    func getIsWatchingSerialWithSid(sid: Int) -> Bool {
        let p = NSPredicate(format: "sid == %d", sid)
        var results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
        var result = (results.count > 0)
        return result
    }
    
    //MARK: -Seasons
    
    private func getSeasonsWithPredicate(predicate: NSPredicate) -> [SMSeason] {
        var results = SMSeason.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMSeason]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMSeason = results.objectAtIndex(i) as! SMSeason
            objects.append(object)
        }
        return objects
    }
    
    func getSeasonsForSid(sid: Int) -> [SMSeason] {
        var p = NSPredicate(format: "sid == %d", sid)
        return self.getSeasonsWithPredicate(p)
    }
    
    //MARK: -Episodes
    
    private func getEpisodesWithPredicate(predicate: NSPredicate) -> [SMEpisode] {
        var results = SMEpisode.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMEpisode]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMEpisode = results.objectAtIndex(i) as! SMEpisode
            objects.append(object)
        }
        return objects
    }
    
    private func getMetaEpisodesWithPredicate(predicate: NSPredicate) -> [SMMetaEpisode] {
        var results = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMMetaEpisode]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMMetaEpisode = results.objectAtIndex(i) as! SMMetaEpisode
            objects.append(object)
        }
        return objects
    }
    
    func getEpisodesForSid(sid: Int) -> [SMEpisode] {
        var p = NSPredicate(format: "sid == %d", sid)
        return self.getEpisodesWithPredicate(p)
    }
    
    func getMetaEpisodesForSid(sid: Int) -> [SMMetaEpisode] {
        var p = NSPredicate(format: "sid == %d", sid)
        return self.getMetaEpisodesWithPredicate(p)
    }
    
    func getMetaEpisodesForSeasonId(season_id: Int) -> [SMMetaEpisode] {
        var p = NSPredicate(format: "season_id == %d", season_id)
        return self.getMetaEpisodesWithPredicate(p)
    }
    
    func getEpisodeProgress(forSeasonId season_id: Int, episodeNumber episode_number: Int) -> SMEpisodeProgress? {
        var p = NSPredicate(format: "season_id == %d and episode_number == %d", season_id, episode_number)
        var results = SMEpisodeProgress.objectsInRealm(self.realm(), withPredicate: p)
        var episodeProgress: SMEpisodeProgress?
        if results.count > 0 {
            episodeProgress = results.firstObject() as? SMEpisodeProgress
        }
        return episodeProgress
    }
    
    func setPlayingProgress(progress: Double, forSeasonId season_id: Int, episodeNumber episode_number: Int) {
        self.realm().beginWriteTransaction()
        var p = NSPredicate(format: "season_id == %d and episode_number == %d", season_id, episode_number)
        var results = SMEpisodeProgress.objectsInRealm(self.realm(), withPredicate: p)
        var episodeProgress: SMEpisodeProgress
        if results.count < 1 {
            episodeProgress = SMEpisodeProgress()
            self.realm().addObject(episodeProgress)
        } else {
            episodeProgress = results.firstObject() as! SMEpisodeProgress
        }
        episodeProgress.season_id = season_id
        episodeProgress.episode_number = episode_number
        episodeProgress.progress = progress
        
        NSLog("%d %d %f", episodeProgress.season_id, episodeProgress.episode_number, episodeProgress.progress)
        
        self.realm().commitWriteTransaction()
    }
    
    //MARK: -Schedule
    
    private func getMyScheduleItemsSids() -> [Int] {
        var results = SMMyScheduleItem.allObjectsInRealm(self.realm())
        var sids = [Int]()
        for var i:UInt = 0; i < results.count; i++ {
            var object: SMMyScheduleItem = results.objectAtIndex(i) as! SMMyScheduleItem
            sids.append(object.sid)
        }
        return sids
        
    }
    
    private func getScheduleItemsWithPredicate(predicate: NSPredicate?) -> [SMScheduleItem] {
        var results: RLMResults
        if let p = predicate {
            results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
        } else {
            results = SMScheduleItem.allObjectsInRealm(self.realm())
        }
        var objects = [SMScheduleItem]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMScheduleItem = results.objectAtIndex(i) as! SMScheduleItem
            objects.append(object)
        }
        return objects
    }
    
    func getScheduleItemsMy() -> [SMScheduleItem] {
        var sids = self.getMyScheduleItemsSids()
        var p = NSPredicate(format: "sid in %@", sids)
        return self.getScheduleItemsWithPredicate(p)
    }
    
    func getScheduleItemsAll() -> [SMScheduleItem] {
        return self.getScheduleItemsWithPredicate(nil)
    }
    
    //MARK: API
    
    //MARK: -Get
    
    func apiGetSerialsMy() {
        let urlStr = "\(SMApiHelper.API_SERIALS_MY)/?nodesc"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                self.realm().beginWriteTransaction()
                var results = SMMySerial.allObjectsInRealm(self.realm())
                self.realm().deleteObjects(results)
                
                for object in objects {
                    if let objectDict = object as? [String: AnyObject] {
                        let sid = objectDict["sid"] as! String
                        let p = NSPredicate(format: "sid = %d", (sid as NSString).integerValue)
                        var results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
                        var serial: SMSerial
                        if results.count > 0 {
                            serial = results.firstObject() as! SMSerial
                        } else {
                            serial = SMSerial()
                            self.realm().addObject(serial)
                        }
                        serial.fillWithDict(objectDict)
                        var mySerial = SMMySerial()
                        self.realm().addObject(mySerial)
                        mySerial.sid = serial.sid
                    }
                }
                self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetSerialsMySucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialsMyFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetSerialsAll() {
        let urlStr = "\(SMApiHelper.API_SERIALS_ALL)/?nodesc"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                
                self.realm().beginWriteTransaction()
                var results = SMSerial.allObjectsInRealm(self.realm())
                self.realm().deleteObjects(results)
                
                for object in objects {
                    if let objectDict = object as? [String: AnyObject] {
                        let sid = objectDict["sid"] as! String
                        let p = NSPredicate(format: "sid = %d", (sid as NSString).integerValue)
                        var results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
                        var serial: SMSerial
                        if results.count > 0 {
                            serial = results.firstObject() as! SMSerial
                        } else {
                            serial = SMSerial()
                            self.realm().addObject(serial)
                        }
                        serial.fillWithDict(objectDict)
                    }
                }
                self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetSerialsAllSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialsAllFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetSerialMetaForSid(sid: Int) {
        let urlStr = "\(SMApiHelper.API_SERIAL_META)/\(sid)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let object:[String:AnyObject] = responseObject["object"] as? [String:AnyObject] {
                let p = NSPredicate(format: "sid = %d", sid)
                
                self.realm().beginWriteTransaction()
                var results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
                for var i:UInt = 0; i < results.count; i++ {
                    var serial = results.objectAtIndex(i) as! SMSerial
                    serial.fillWithDict(object)
                }
                
                self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetSerialMetaSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialMetaFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetEpisodesForSid(sid: Int) {
        let urlStr = "\(SMApiHelper.API_EPISODES)/\(sid)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                self.realm().beginWriteTransaction()
                let p = NSPredicate(format: "sid = %d", sid)
                var results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
                self.realm().deleteObjects(results)
                results = SMSeason.objectsInRealm(self.realm(), withPredicate: p)
                self.realm().deleteObjects(results)
                results = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: p)
                self.realm().deleteObjects(results)
                
                for object in objects {
                    if let objectDict = object as? [String: AnyObject] {
                        let eid = objectDict["eid"] as! String
                        var p = NSPredicate(format: "eid = %d", (eid as NSString).integerValue)
                        var results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
                        var episode: SMEpisode
                        if results.count > 0 {
                            episode = results.firstObject() as! SMEpisode
                        } else {
                            episode = SMEpisode()
                            self.realm().addObject(episode)
                        }
                        episode.fillWithDict(objectDict)
                        
                        p = NSPredicate(format: "season_id = %d", episode.season_id)
                        results = SMSeason.objectsInRealm(self.realm(), withPredicate: p)
                        if (results.count < 1) {
                            var season = SMSeason()
                            self.realm().addObject(season)
                            season.season_id = episode.season_id
                            season.sid = episode.sid
                            season.season_number = episode.season
                        }
                        
                        p = NSPredicate(format: "sid = %d and season_id = %d and episode = %d", episode.sid, episode.season_id, episode.episode)
                        results = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: p)
                        var metaEpisode: SMMetaEpisode
                        if (results.count < 1) {
                            metaEpisode = SMMetaEpisode()
                            self.realm().addObject(metaEpisode)
                        } else {
                            metaEpisode = results.firstObject() as! SMMetaEpisode
                        }
                        metaEpisode.appendEpisode(episode)                                                
                    }
                }
                self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetEpisodesSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetEpisodesFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetLinkInfoForEid(eid: Int, sid: Int, hash: String) {
        let urlStr = "\(SMApiHelper.API_EPISODE_TOGGLE_WATCHED)"
        var link: String?
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let server = responseObject["server"] as? String {
                if let t = SMStateManager.sharedInstance.token {
                    self.realm().beginWriteTransaction()
                    let p = NSPredicate(format: "eid = %d", eid)
                    var results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
                    link = SMApiHelper.makeLink(server, token: t, eid: eid, sid: sid, hash: hash)
                    for var i:UInt = 0; i < results.count; i++ {
                        var episode:SMEpisode = results.objectAtIndex(i) as! SMEpisode
                        episode.link = link!
                    }
                    self.realm().commitWriteTransaction()
                }
            }
            
            postNotification(SMCatalogManagerNotification.ApiEpisodeGetLinkInfoSucceed.rawValue, link)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiEpisodeGetLinkInfoFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
            params["hash"] = SMApiHelper.makeHash(t, eid: eid, hash: hash, sid: sid)
        }
        
        params["what"] = "player"
        params["do"] = "load"
        params["eid"] = eid
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetScheduleMy() {
        let urlStr = "\(SMApiHelper.API_SCHEDULE_MY)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            var results = SMMyScheduleItem.allObjectsInRealm(self.realm())
            self.realm().deleteObjects(results)
            
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                for object in objects {
                    if let objectDict = object as? [String:AnyObject] {
                        var sid = objectDict["sid"] as! NSString
                        var p = NSPredicate(format: "sid = %d", sid.integerValue)
                        var results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
                        var scheduleItem: SMScheduleItem? = results.firstObject() as? SMScheduleItem
                        
                        if scheduleItem == nil {
                            scheduleItem = SMScheduleItem()
                            self.realm().addObject(scheduleItem)
                        }
                        
                        scheduleItem?.fillWithDict(objectDict)
                        var msi = SMMyScheduleItem(scheduleItem: scheduleItem!)
                        self.realm().addObject(msi)
                    }
                }
            }
            
            self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiGetScheduleAll() {
        let urlStr = "\(SMApiHelper.API_SCHEDULE_ALL)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            var sids = self.getMyScheduleItemsSids()
            var p = NSPredicate(format: "not sid in %@", sids)
            var results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
            self.realm().deleteObjects(results)
            
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                for object in objects {
                    if let objectDict = object as? [String:AnyObject] {
                        var sid = objectDict["sid"] as! NSString
                        var p = NSPredicate(format: "sid = %d", sid.integerValue)
                        var results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
                        var scheduleItem: SMScheduleItem? = results.firstObject() as? SMScheduleItem
                        
                        if scheduleItem == nil {
                            scheduleItem = SMScheduleItem()
                            self.realm().addObject(scheduleItem)
                        }
                        
                        scheduleItem?.fillWithDict(objectDict)
                    }
                }
            }
            
            self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    //MARK: -Actions
    
    func apiMarkSerialWatching(sid: Int) {
        let urlStr = "\(SMApiHelper.API_SERIAL_MARK_WATCHING)/\(sid)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            var p = NSPredicate(format: "sid = %d", sid)
            var results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
            
            if (results.count < 1) {
                var mySerial = SMMySerial()
                self.realm().addObject(mySerial)
                mySerial.sid = sid
            }
                        
            self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiMarkSerialNotWatching(sid: Int) {
        let urlStr = "\(SMApiHelper.API_SERIAL_MARK_NOT_WATCHING)/\(sid)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            var p = NSPredicate(format: "sid = %d", sid)
            var results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
            self.realm().deleteObjects(results)
            self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue, nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiMarkEpisodeWatched(eid: Int, watched: Bool) {
        let urlStr = "\(SMApiHelper.API_EPISODE_TOGGLE_WATCHED)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            var metaEpisode: SMMetaEpisode?
            self.realm().beginWriteTransaction()
            var p = NSPredicate(format: "eid = %d", eid)
            var results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
            if results.count > 0 {
                let episode:SMEpisode = results.firstObject() as! SMEpisode
                p = NSPredicate(format: "season_id = %d and episode = %d", episode.season_id, episode.episode)
                results = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: p)
                if let me = results.firstObject() as? SMMetaEpisode {
                    for var i: UInt = 0; i < me.episodes.count; i++ {
                        var episode:SMEpisode = me.episodes.objectAtIndex(i) as! SMEpisode
                        episode.watched = watched
                    }
                    me.watched = watched
                    metaEpisode = me
                }
            }
            self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiEpisodeToggleWatchedSucceed.rawValue, metaEpisode?.episode)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiEpisodeToggleWatchedFailed.rawValue, error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        if watched {
            params["what"] = "mark_watched"
        } else {
            params["what"] = "mark_unwatched"
        }
        
        params["eid"] = eid
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
}



