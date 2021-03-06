//
//  SMCatalogManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Realm
import CoreSpotlight
import SDWebImage

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
    
    case ApiSeasonMarkWatchedSucceed = "ApiSeasonMarkWatchedSucceed"
    case ApiSeasonMarkWatchedFailed = "ApiSeasonMarkWatchedFailed"
    
    case ApiEpisodeToggleWatchedSucceed = "ApiEpisodeToggleWatchedSucceed"
    case ApiEpisodeToggleWatchedFailed = "ApiEpisodeToggleWatchedFailed"
    
    case ApiEpisodeGetLinkInfoSucceed = "ApiEpisodeGetLinkInfoSucceed"
    case ApiEpisodeGetLinkInfoFailed = "ApiEpisodeGetLinkInfoFailed"
    
    case ApiGetScheduleSucceed = "ApiGetScheduleSucceed"
    case ApiGetScheduleFailed = "ApiGetScheduleFailed"
    
    case ApiGetScheduleForSerialSucceed = "ApiGetScheduleForSerialSucceed"
    case ApiGetScheduleForSerialFailed = "ApiGetScheduleForSerialFailed"
}

class SMCatalogManager: NSObject {
    
    static let sharedInstance = SMCatalogManager()
    
    private var _realm: RLMRealm?
    
    private func realm() -> RLMRealm
    {
        if _realm == nil
        {
            let config = RLMRealmConfiguration()
            var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String!
            path = path.stringByAppendingString("/db_\(DB_VERSION).realm")
            config.path = path
            config.schemaVersion = SCHEMA_VERSION
            
            config.migrationBlock = {(migration, oldSchemaVersion) in
                
            }
            
            try! self._realm = RLMRealm(configuration: config)
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
        
        try! self.realm().commitWriteTransaction()
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
        let results = SMMySerial.allObjectsInRealm(self.realm())
        var sids = [Int]()
        for var i:UInt = 0; i < results.count; i++ {
            let ms: SMMySerial = results.objectAtIndex(i) as! SMMySerial
            sids.append(ms.sid)
        }
        return sids
    }
    
    func getSerialsMy() -> [SMSerial]  {
        let sids = self.getMySerialsSids()
        let p = NSPredicate(format: "sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyUnwatched() -> [SMSerial]  {
        let sids = self.getMySerialsSids()
        let p = NSPredicate(format: "unwatched > 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyWatched() -> [SMSerial]  {
        let sids = self.getMySerialsSids()
        let p = NSPredicate(format: "unwatched == 0 and status == 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyEnded() -> [SMSerial]  {
        let sids = self.getMySerialsSids()
        let p = NSPredicate(format: "unwatched == 0 and status != 0 and sid in %@", sids)
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsAll() -> [SMSerial] {
        return self.getSerialsWithPredicate(nil)
    }
    
    func getSerialWithSid(sid: Int) -> SMSerial? {
        let p = NSPredicate(format: "sid == %d", sid)
        let serials = self.getSerialsWithPredicate(p)
        return serials.first
    }
    
    func getIsWatchingSerialWithSid(sid: Int) -> Bool {
        let p = NSPredicate(format: "sid == %d", sid)
        let results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
        let result = (results.count > 0)
        return result
    }
    
    //MARK: -Seasons
    
    private func getSeasonsWithPredicate(predicate: NSPredicate) -> [SMSeason] {
        let results = SMSeason.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMSeason]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMSeason = results.objectAtIndex(i) as! SMSeason
            objects.append(object)
        }
        return objects
    }
    
    func getSeasonsForSid(sid: Int) -> [SMSeason] {
        let p = NSPredicate(format: "sid == %d", sid)
        return self.getSeasonsWithPredicate(p)
    }
    
    //MARK: -Episodes
    
    private func getEpisodesWithPredicate(predicate: NSPredicate) -> [SMEpisode] {
        let results = SMEpisode.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMEpisode]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMEpisode = results.objectAtIndex(i) as! SMEpisode
            objects.append(object)
        }
        return objects
    }
    
    private func getMetaEpisodesWithPredicate(predicate: NSPredicate) -> [SMMetaEpisode] {
        let results = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMMetaEpisode]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMMetaEpisode = results.objectAtIndex(i) as! SMMetaEpisode
            objects.append(object)
        }
        return objects
    }
    
    func getEpisodesForSid(sid: Int) -> [SMEpisode] {
        let p = NSPredicate(format: "sid == %d", sid)
        return self.getEpisodesWithPredicate(p)
    }
    
    func getMetaEpisodesForSid(sid: Int) -> [SMMetaEpisode] {
        let p = NSPredicate(format: "sid == %d", sid)
        return self.getMetaEpisodesWithPredicate(p)
    }
    
    func getMetaEpisodesForSeasonId(season_id: Int) -> [SMMetaEpisode] {
        let p = NSPredicate(format: "season_id == %d", season_id)
        return self.getMetaEpisodesWithPredicate(p)
    }
    
    func getEpisodeWithEid(eid: Int) -> SMEpisode? {
        let p = NSPredicate(format: "eid == %d", eid)
        let results = self.getEpisodesWithPredicate(p)
        var episode: SMEpisode? = nil
        episode = results.first
        return episode
    }
    
    func getEpisodeProgress(forSeasonId season_id: Int, episodeNumber episode_number: Int) -> SMEpisodeProgress? {
        let p = NSPredicate(format: "season_id == %d and episode_number == %d", season_id, episode_number)
        let results = SMEpisodeProgress.objectsInRealm(self.realm(), withPredicate: p)
        var episodeProgress: SMEpisodeProgress?
        if results.count > 0 {
            episodeProgress = results.firstObject() as? SMEpisodeProgress
        }
        return episodeProgress
    }
    
    func setPlayingProgress(progress: Double, forSeasonId season_id: Int, episodeNumber episode_number: Int) {
        self.realm().beginWriteTransaction()
        let p = NSPredicate(format: "season_id == %d and episode_number == %d", season_id, episode_number)
        let results = SMEpisodeProgress.objectsInRealm(self.realm(), withPredicate: p)
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
        
        try! self.realm().commitWriteTransaction()
    }
    
    //MARK: -Schedule
    
    private func getMyScheduleItemsSids() -> [Int] {
        let results = SMMyScheduleItem.allObjectsInRealm(self.realm())
        var sids = [Int]()
        for var i:UInt = 0; i < results.count; i++ {
            let object: SMMyScheduleItem = results.objectAtIndex(i) as! SMMyScheduleItem
            sids.append(object.sid)
        }
        return sids
    }
    
    private func getSerialScheduleItemsSids() -> [Int] {
        let results = SMSerialScheduleItem.allObjectsInRealm(self.realm())
        var sids = [Int]()
        for var i:UInt = 0; i < results.count; i++ {
            let object: SMMyScheduleItem = results.objectAtIndex(i) as! SMMyScheduleItem
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
        let sids = self.getMyScheduleItemsSids()
        let p = NSPredicate(format: "sid in %@", sids)
        return self.getScheduleItemsWithPredicate(p)
    }
    
    func getScheduleItemsAll() -> [SMScheduleItem] {
        return self.getScheduleItemsWithPredicate(nil)
    }
    
    func getScheduleItemsForSid(sid: Int) -> [SMSerialScheduleItem] {
        let p = NSPredicate(format: "sid = %d", sid)
        let results = SMSerialScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
        var objects = [SMSerialScheduleItem]()
        for var i: UInt = 0; i < results.count; i++ {
            let object: SMSerialScheduleItem = results.objectAtIndex(i) as! SMSerialScheduleItem
            objects.append(object)
        }
        return objects
    }
    
    //MARK: API
    
    //MARK: -Get
    
    func apiGetSerialsMy() {
        let urlStr = "\(SMApiHelper.API_SERIALS_MY)/?nodesc"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject]
            {
                self.realm().beginWriteTransaction()
                
                let results = SMMySerial.allObjectsInRealm(self.realm())
                self.realm().deleteObjects(results)
                var indexed = [SMIndexedObject]()
                
                for object in objects
                {
                    if let objectDict = object as? [String: AnyObject] {
                        let sid = objectDict["sid"] as! String
                        let p = NSPredicate(format: "sid = %d", (sid as NSString).integerValue)
                        let results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
                        var serial: SMSerial
                        if results.count > 0 {
                            serial = results.firstObject() as! SMSerial
                        } else {
                            serial = SMSerial()
                            self.realm().addObject(serial)
                        }
                        serial.fillWithDict(objectDict)
                        let mySerial = SMMySerial()
                        self.realm().addObject(mySerial)
                        mySerial.sid = serial.sid
                        indexed.append(serial.indexedObject())
                    }
                }
                
                self.reindexSpotlightWithSerials(indexed)
                try! self.realm().commitWriteTransaction()
                
                postNotification(SMCatalogManagerNotification.ApiGetSerialsMySucceed.rawValue, object: nil)
            }
        }
        
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialsMyFailed.rawValue, object: error)
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func reindexSpotlightWithSerials(objects: [SMIndexedObject])
    {
        if #available(iOS 9.0, *)
        {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler(nil)
                self.tryAddSerialsToSpotlight(objects)
            })
        }
    }
    
    func tryAddSerialsToSpotlight(objects: [SMIndexedObject])
    {
        if #available(iOS 9.0, *)
        {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                var items = [CSSearchableItem]()
                let bundleId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
                for object in objects
                {
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: "")
                    attributeSet.title = object.title
                    attributeSet.contentDescription = object.desc
                    if let urlStr = self.cahcedImageUrlForURL(object.imageURL)
                    {
                        attributeSet.thumbnailURL = NSURL(fileURLWithPath: urlStr)
                    }
                    let item = CSSearchableItem(uniqueIdentifier: object.identifier, domainIdentifier: bundleId, attributeSet: attributeSet)
                    items.append(item)
                }
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(items, completionHandler: { (error) -> Void in
                })
            })
        }
    }
    
    func updateSerialIndexWithSid(sid: Int, imageURL: String?)
    {
        if (imageURL == nil)
        {
            return
        }
        if #available(iOS 9.0, *)
        {
            if let serial = self.getSerialWithSid(sid)
            {
                let object = serial.indexedObject()
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                    let bundleId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: "")
                    attributeSet.title = object.title
                    attributeSet.contentDescription = object.desc
                    if let urlStr = self.cahcedImageUrlForURL(object.imageURL)
                    {
                        attributeSet.thumbnailURL = NSURL(fileURLWithPath: urlStr)
                    }
                    let item = CSSearchableItem(uniqueIdentifier: object.identifier, domainIdentifier: bundleId, attributeSet: attributeSet)
                    CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item], completionHandler: nil)                
                })
            }
        }
    }
    
    func tryRemoveSerialWithSidFromSpotlight(sid: Int)
    {
        if #available(iOS 9.0, *)
        {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { () -> Void in
                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([String(format: "%ld", sid)], completionHandler: nil)
            })
        }
    }
    
    func addSerialToSpotlightWithSid(sid: Int)
    {
        let p = NSPredicate(format: "sid = %d", sid)
        var results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
    
        if (results.count > 0)
        {
            results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
            if (results.count > 0)
            {
                if let serial = results.firstObject() as? SMSerial
                {
                    let object = serial.indexedObject()
                    self.tryAddSerialsToSpotlight([object])
                }
            }
        }
    }
    
    func cahcedImageUrlForURL(imageUrl: String?) -> String?
    {
        var path: String?
        if let _ = imageUrl
        {
            if let url = NSURL(string: imageUrl!, relativeToURL: nil)
            {
                if SDWebImageManager.sharedManager().cachedImageExistsForURL(url)
                {
                    let key = SDWebImageManager.sharedManager().cacheKeyForURL(url)
                    path = SDImageCache.sharedImageCache().defaultCachePathForKey(key)
                }
            }
        }
        return path
    }
    
    func apiGetSerialsAll() {
        let urlStr = "\(SMApiHelper.API_SERIALS_ALL)/?nodesc"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                
                self.realm().beginWriteTransaction()
                let results = SMSerial.allObjectsInRealm(self.realm())
                self.realm().deleteObjects(results)
                
                for object in objects {
                    if let objectDict = object as? [String: AnyObject] {
                        let sid = objectDict["sid"] as! String
                        let p = NSPredicate(format: "sid = %d", (sid as NSString).integerValue)
                        let results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
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
                try! self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetSerialsAllSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialsAllFailed.rawValue, object: error)
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
                let results = SMSerial.objectsInRealm(self.realm(), withPredicate: p)
                if results.count > 0 {
                    for var i:UInt = 0; i < results.count; i++ {
                        let serial = results.objectAtIndex(i) as! SMSerial
                        serial.fillWithDict(object)
                    }
                } else {
                    let serial = SMSerial()
                    self.realm().addObject(serial)
                    serial.fillWithDict(object)
                }
                
                try! self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetSerialMetaSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetSerialMetaFailed.rawValue, object: error)
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
                            let season = SMSeason()
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
                try! self.realm().commitWriteTransaction()
            }
            
            postNotification(SMCatalogManagerNotification.ApiGetEpisodesSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetEpisodesFailed.rawValue, object: error)
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
                    let results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
                    link = SMApiHelper.makeLink(server, token: t, eid: eid, sid: sid, hash: hash)
                    for var i:UInt = 0; i < results.count; i++ {
                        let episode:SMEpisode = results.objectAtIndex(i) as! SMEpisode
                        episode.link = link!
                    }
                    try! self.realm().commitWriteTransaction()
                }
            }
            
            postNotification(SMCatalogManagerNotification.ApiEpisodeGetLinkInfoSucceed.rawValue, object: link)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiEpisodeGetLinkInfoFailed.rawValue, object: error)
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
            let results = SMMyScheduleItem.allObjectsInRealm(self.realm())
            self.realm().deleteObjects(results)
            
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                for object in objects {
                    if let objectDict = object as? [String:AnyObject] {
                        let sid = objectDict["sid"] as! NSString
                        let p = NSPredicate(format: "sid = %d", sid.integerValue)
                        let results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
                        var scheduleItem: SMScheduleItem? = results.firstObject() as? SMScheduleItem
                        
                        if scheduleItem == nil {
                            scheduleItem = SMScheduleItem()
                            self.realm().addObject(scheduleItem!)
                        }
                        
                        scheduleItem?.fillWithDict(objectDict)
                        let msi = SMMyScheduleItem(scheduleItem: scheduleItem!)
                        self.realm().addObject(msi)
                    }
                }
            }
            
            try! self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue, object: error)
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
            let sids = self.getMyScheduleItemsSids()
            let p = NSPredicate(format: "not sid in %@", sids)
            let results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
            self.realm().deleteObjects(results)
            
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                for object in objects {
                    if let objectDict = object as? [String:AnyObject] {
                        let sid = objectDict["sid"] as! NSString
                        var episode: Int = 0
                        var season: Int = 0
                        if let ps = objectDict["episode"] as? String {
                            var ss = ps.substringFromIndex(ps.startIndex.advancedBy(4))
                            episode = (ss as NSString).integerValue
                            ss = ps.substringFromIndex(ps.startIndex.advancedBy(1))
                            ss = ss.substringToIndex(ss.startIndex.advancedBy(2))
                            season = (ss as NSString).integerValue
                        }
                        let p = NSPredicate(format: "sid = %d and season_number = %d and episode_number = %d", sid.integerValue, season, episode)
                        let results = SMScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
                        var scheduleItem: SMScheduleItem? = results.firstObject() as? SMScheduleItem
                        
                        if scheduleItem == nil {
                            scheduleItem = SMScheduleItem()
                            self.realm().addObject(scheduleItem!)
                        }
                        
                        scheduleItem?.fillWithDict(objectDict)
                    }
                }
            }
            
            try! self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue, object: error)
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
    
    func apiGetScheduleForSid(sid: Int) {
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            let p = NSPredicate(format: "sid = %d", sid)
            let results = SMSerialScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
            self.realm().deleteObjects(results)
            
            let serial:SMSerial? = self.getSerialWithSid(sid)
            
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                for object in objects {
                    if let objectDict = object as? [String:AnyObject] {
                        var episode: Int = 0
                        var season: Int = 0
                        if let ps = objectDict["episode"] as? String {
                            var ss = ps.substringFromIndex(ps.startIndex.advancedBy(4))
                            episode = (ss as NSString).integerValue
                            ss = ps.substringFromIndex(ps.startIndex.advancedBy(1))
                            ss = ss.substringToIndex(ss.startIndex.advancedBy(2))
                            season = (ss as NSString).integerValue
                        }
                        let p = NSPredicate(format: "sid = %d and season_number = %d and episode_number = %d", sid, season, episode)
                        
                        let results = SMSerialScheduleItem.objectsInRealm(self.realm(), withPredicate: p)
                        var scheduleItem: SMSerialScheduleItem? = results.firstObject() as? SMSerialScheduleItem
                        
                        if scheduleItem == nil {
                            scheduleItem = SMSerialScheduleItem()
                            self.realm().addObject(scheduleItem!)
                        }
                        scheduleItem?.fillWithDict(objectDict)
                        scheduleItem?.sid = sid
                        if let name = serial?.title {
                            scheduleItem?.serial_name = name
                        }
                    }
                }
            }
            
            try! self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiGetScheduleForSerialSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiGetScheduleForSerialFailed.rawValue, object: error)
        }
        
        let urlStr = "\(SMApiHelper.API_SCHEDULE_SERIAL)/\(sid)"
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
            let p = NSPredicate(format: "sid = %d", sid)
            let results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
            
            if (results.count < 1) {
                let mySerial = SMMySerial()
                self.realm().addObject(mySerial)
                mySerial.sid = sid
            }
                        
            try! self.realm().commitWriteTransaction()
            
            self.addSerialToSpotlightWithSid(sid)
            
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue, object: error)
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
            let p = NSPredicate(format: "sid = %d", sid)
            let results = SMMySerial.objectsInRealm(self.realm(), withPredicate: p)
            self.realm().deleteObjects(results)
            try! self.realm().commitWriteTransaction()
            
            self.tryRemoveSerialWithSidFromSpotlight(sid)
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue, object: error)
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
                        let episode:SMEpisode = me.episodes.objectAtIndex(i) as! SMEpisode
                        episode.watched = watched
                    }
                    me.watched = watched
                    metaEpisode = me
                }
                self.addSerialToSpotlightWithSid(episode.sid)
            }
            try! self.realm().commitWriteTransaction()
            
            postNotification(SMCatalogManagerNotification.ApiEpisodeToggleWatchedSucceed.rawValue, object: metaEpisode?.episode)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiEpisodeToggleWatchedFailed.rawValue, object: error)
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
    
    func apiMarkSeasonWatchedForSid(sid: Int, season: Int) {
        let urlStr = "\(SMApiHelper.API_SEASON_MARK_WATCHED)"
        
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.realm().beginWriteTransaction()
            var p = NSPredicate(format: "sid = %d and season = %d", sid, season)
            let results = SMEpisode.objectsInRealm(self.realm(), withPredicate: p)
            for var i: UInt = 0; i < results.count; i++ {
                let episode:SMEpisode = results[i] as! SMEpisode
                p = NSPredicate(format: "season_id = %d and episode = %d and sid = %d", episode.season_id, episode.episode, sid)
                let r = SMMetaEpisode.objectsInRealm(self.realm(), withPredicate: p)
                if let me = r.firstObject() as? SMMetaEpisode {
                    me.watched = true
                }
            }
            try! self.realm().commitWriteTransaction()
            
            self.addSerialToSpotlightWithSid(sid)
            
            postNotification(SMCatalogManagerNotification.ApiSeasonMarkWatchedSucceed.rawValue, object: nil)
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMCatalogManagerNotification.ApiSeasonMarkWatchedFailed.rawValue, object: error)
        }
        
        var params = [String:NSObject]()
        if let t = SMStateManager.sharedInstance.token {
            params["token"] = t
        }
        params["what"] = "mark_full"
        params["sid"] = sid
        params["season"] = season
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
}



