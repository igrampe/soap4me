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
}

class SMCatalogManager: NSObject {
    
    static let sharedInstance = SMCatalogManager()
    
    private var _realm: RLMRealm?
    
    func realm() -> RLMRealm {
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
    
    func apiGetSerialsMy() {
        
        let urlStr = "\(SMApiHelper.sharedInstance.API_SERIALS_MY)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let objects:[AnyObject] = responseObject["objects"] as? [AnyObject] {
                self.realm().beginWriteTransaction()
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
                        serial.setValue(true, forKey: "my")
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
    
    func getSerialsWithPredicate(predicate: NSPredicate) -> [SMSerial] {
        var results = SMSerial.objectsInRealm(self.realm(), withPredicate: predicate)
        var objects = [SMSerial]()
        for var i: UInt = 0; i < results.count; i++ {
            let serial: SMSerial = results.objectAtIndex(i) as! SMSerial
            objects.append(serial)
        }
        return objects
    }
    
    func getSerialsMyUnwatched() -> [SMSerial]  {
        var p = NSPredicate(format: "my == true and unwatched > 0")
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyWatched() -> [SMSerial]  {
        var p = NSPredicate(format: "my == true and unwatched == 0 and status == 0")
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsMyEnded() -> [SMSerial]  {
        var p = NSPredicate(format: "my == true and unwatched == 0 and status != 0")
        return self.getSerialsWithPredicate(p)
    }
    
    func getSerialsAll() -> [SMSerial] {
        var p = NSPredicate()
        return self.getSerialsWithPredicate(p)
    }
}



