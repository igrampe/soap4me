//
//  SMStateManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import KeychainAccess
import Appirater

let APP_ID = 1023531443

private enum UserDefaultsKeys: String {
    case PassVersion = "PassVersion"
    
    case Token = "Token"
    case TokenTill = "TokenTill"
    
    case UserLogin = "UserLogin"
    case UserPassowrd = "UserPassowrd"
    
    case PreferedQuality = "PreferedQuality"
    case PreferedTranslation = "PreferedTranslation"
    
    case SubscribedToPush = "SubscribedToPush"
    case ShouldSubscribeToPush = "ShouldSubscribeToPush"
    case PushToken = "PushToken"
    
    case CatalogSorting = "CatalogSorting"
    
    case ShouldContinueWithNextEpisode = "ShouldContinueWithNextEpisode"
    
    case LastPlayingEid = "LastPlayingEid"
//    var stringValue: String {
//        switch self {
//            case .Token: return "TOKEN"
//            case .TokenTill: return "TOKEN_TILL"
//        }
//    }
}

public enum SMStateManagerNotification: String {
    case SignInSucceed = "SignInSucceed"
    case SignInFailed = "SignInFailed"
    
    case StateCleared = "StateCleared"
    
//    var stringVale: String {
//        switch self {
//        case .SignInSucceed: return "SMStateManagerNotification.\(SignInSucceed)";
//        case .SignInFailed: return "SMStateManagerNotification.\(SignInFailed)";
//        }
//    }
    
}

enum SMSorting: Int {
    case Ascending = 0
    case Descending = 1
}

class SMStateManager: NSObject, AppiraterDelegate {
    static let sharedInstance = SMStateManager()
    
    var keychain: Keychain!
    
    var subscribedToPush = false {
        didSet {
            self.saveBoolValue(subscribedToPush, key: UserDefaultsKeys.SubscribedToPush.rawValue)
        }
    }
    
    var shouldSubscribeToPush = true {
        didSet {
            self.saveBoolValue(shouldSubscribeToPush, key: UserDefaultsKeys.ShouldSubscribeToPush.rawValue)
            if shouldSubscribeToPush {
                self.registerPush()
            }
        }
    }
    
    var pushToken = "" {
        didSet {
            self.saveValue(pushToken, key: UserDefaultsKeys.PushToken.rawValue)
            self.checkPush()
        }
    }
    
    var userLogin: String? {
        didSet {
            self.saveKeychainValue(userLogin, key: UserDefaultsKeys.UserLogin.rawValue)
        }
    }
    var userPassoword: String? {
        didSet {
            self.saveKeychainValue(userPassoword, key: UserDefaultsKeys.UserPassowrd.rawValue)
        }
    }
    
    var preferedQuality: SMEpisodeQuality! {
        didSet {
            self.saveValue(preferedQuality.rawValue, key: UserDefaultsKeys.PreferedQuality.rawValue)
        }
    }
    
    var preferedTranslation: SMEpisodeTranslateType! {
        didSet {
            self.saveValue(preferedTranslation.rawValue, key: UserDefaultsKeys.PreferedTranslation.rawValue)
        }
    }
    
    var catalogSorting: SMSorting! {
        didSet {
            self.saveValue(catalogSorting.rawValue, key: UserDefaultsKeys.CatalogSorting.rawValue)
        }
    }

    var shouldContinueWithNextEpisode: Bool = true {
        didSet {
            self.saveBoolValue(shouldContinueWithNextEpisode, key: UserDefaultsKeys.ShouldContinueWithNextEpisode.rawValue)
        }
    }
    
    var lastPlayingEid: Int = 0 {
        didSet {
            self.saveValue(lastPlayingEid, key: UserDefaultsKeys.LastPlayingEid.rawValue)
        }
    }
    
    private(set) var token: String? {
        didSet {
            self.saveValue(token, key: UserDefaultsKeys.Token.rawValue)
            if let t = self.token {
                SMApiHelper.sharedInstance.setToken(t)
            }
        }
    }
    private(set) var tokenTill: NSDate? {
        didSet {
            self.saveValue(tokenTill, key: UserDefaultsKeys.TokenTill.rawValue)
        }
    }
    
    var passVersion: String! {
        didSet {
            self.saveValue(passVersion, key: UserDefaultsKeys.PassVersion.rawValue)
        }
    }
    
    var currentVersion: String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    
    override init() {
        super.init()
        
        Appirater.setDelegate(self)
        
        if let bundleId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String {
            self.keychain = Keychain(service: bundleId)
        }
        
        if let pv = self.getValueForKey(UserDefaultsKeys.PassVersion.rawValue) as? String {
            self.passVersion = pv
        } else {
            self.passVersion = "0.0.0"
        }
        
        if let pq = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.PreferedQuality.rawValue) as? SMEpisodeQuality.RawValue {
            preferedQuality = SMEpisodeQuality(rawValue: pq)
        } else {
            preferedQuality = SMEpisodeQuality.HD
        }
        
        if let pt = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.PreferedTranslation.rawValue) as? SMEpisodeTranslateType.RawValue {
            preferedTranslation = SMEpisodeTranslateType(rawValue: pt)
        } else {
            preferedTranslation = SMEpisodeTranslateType.Voice
        }

        if let t = self.getValueForKey(UserDefaultsKeys.Token.rawValue) as? String {
            token = t
            SMApiHelper.sharedInstance.setToken(self.token!)
        }

        if let tt = self.getValueForKey(UserDefaultsKeys.TokenTill.rawValue) as? NSDate {
            tokenTill = tt
        }
        
        if let pt = self.getValueForKey(UserDefaultsKeys.PushToken.rawValue) as? String {
            pushToken = pt
        }
        
        self.shouldSubscribeToPush = self.getBoolValueForKey(UserDefaultsKeys.ShouldSubscribeToPush.rawValue)
        self.subscribedToPush = self.getBoolValueForKey(UserDefaultsKeys.SubscribedToPush.rawValue)
        
        if let uLogin = self.getKeychainValueForKey(UserDefaultsKeys.UserLogin.rawValue) {
            userLogin = uLogin
        }
        if let uPassword = self.getKeychainValueForKey(UserDefaultsKeys.UserPassowrd.rawValue) {
            userPassoword = uPassword
        }
        
        if let cs = self.getValueForKey(UserDefaultsKeys.CatalogSorting.rawValue) as? Int {
            catalogSorting = SMSorting(rawValue: cs)
        } else {
            catalogSorting = SMSorting.Ascending
        }
        
        shouldContinueWithNextEpisode = self.getBoolValueForKey(UserDefaultsKeys.ShouldContinueWithNextEpisode.rawValue)
        
        if let lpe = self.getValueForKey(UserDefaultsKeys.LastPlayingEid.rawValue) as? Int{
            lastPlayingEid = lpe
        }
    }
    
    func checkVersion() {
        // Fucking Parse SDK doesn't work
        var url = "https://api.parse.com/1/config"
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        if config.HTTPAdditionalHeaders == nil {
            config.HTTPAdditionalHeaders = [NSObject: AnyObject]()
        }
        config.HTTPAdditionalHeaders!["X-Parse-Application-Id"] = "yYwNAXGXKwbtY1890rllhpQUB7c9S1a255SOXilP"
        config.HTTPAdditionalHeaders!["X-Parse-REST-API-Key"] = "6oApZb8bMry48mfounDQDNMWVlMf2zQMhIZnM4MH"
        var session = NSURLSession(configuration: config)
        
        var t = session.dataTaskWithURL(NSURL(string: "https://api.parse.com/1/config")!) { (data, _, _) -> Void in
            var object:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if let o = object as? [String: AnyObject] {
                if let params = o["params"] as? [String: AnyObject] {
                    if let pv = params["PassVersion"] as? String {
                        self.passVersion = pv
                    }
                }
            }
        }
        t.resume()
    }
    
    private func saveValue(value: AnyObject?, key: String) {
        if let v: AnyObject = value {
            NSUserDefaults.standardUserDefaults().setValue(v, forKey: key)
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
    }
    
    private func saveBoolValue(value: Bool, key: String) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func getValueForKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    private func getBoolValueForKey(key: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    private func saveKeychainValue(value: String?, key: String) {
        if let v = value {
            self.keychain.set(v, key: key)
        } else {
            self.keychain.remove(key)
        }
    }
    
    private func saveKeychainValue(value: AnyObject?, key: String) {
        if let v: AnyObject = value {
            var data = NSKeyedArchiver.archivedDataWithRootObject(v)
            self.keychain.set(data, key: key)
        } else {
            self.keychain.remove(key)
        }
    }
    
    private func getKeychainValueForKey(key: String) -> String? {
        return self.keychain.get(key)
    }
    
    private func getKeychainAnyObjectForKey(key: String) -> AnyObject? {
        var object: AnyObject?
        if let data = self.keychain.getData(key) {
            object = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        }
        return object
    }
    
    //MARK: Actions
    
    func logout() {
        self.userLogin = nil
        self.userPassoword = nil
        
        self.clearState()
    }
    
    func clearState() {
        self.token = nil
        self.tokenTill = nil
        
        SMCatalogManager.sharedInstance.clearState()
        
        postNotification(SMStateManagerNotification.StateCleared.rawValue, nil)
    }
    
    //MARK: Getters
    
    func hasValidToken() -> Bool {
        var result = false
        if let t = self.token {
            if t.length() > 0 {
                if let tt = self.tokenTill {
                    result = tt.timeIntervalSince1970 > NSDate().timeIntervalSince1970
                }
            }
        }
        return result
    }
    
    func canPlaySerials() -> Bool {
        var result = true
        var currentVersionComps = self.currentVersion.componentsSeparatedByString(".")
        var passVersionComps = self.passVersion.componentsSeparatedByString(".")
        
        if (vgta(currentVersionComps, passVersionComps, 0)) {
            result = false
        } else if (currentVersionComps.count > 1 && passVersionComps.count > 1) {
            if (vgta(currentVersionComps, passVersionComps, 1)) {
                result = false
            } else if (currentVersionComps.count > 2 && passVersionComps.count > 2) {
                if (vgta(currentVersionComps, passVersionComps, 2)) {
                    result = false
                }
            }
        }
        
        return result
    }
    
    func registerPush() {
        var settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes:UIUserNotificationType.Badge|UIUserNotificationType.Alert|UIUserNotificationType.Sound, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func checkPush() {
        if !self.subscribedToPush {
            if self.pushToken.length() > 0 {
                if self.token?.length() > 0 {
                    self.apiSubscribeToPush()
                }
            }
        }
    }
    
    //MARK: API
    func signIn(login: String, password: String) {
        YMMYandexMetrica.reportEvent("APP.ACTION.SIGNIN.TRY", onFailure: nil)
        
        let urlStr = "\(SMApiHelper.API_LOGIN)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            if let t = responseObject["token"] as? String {
                self.token = t
            } else {
                self.token = nil
            }
            if let t = responseObject["till"] as? String {
                let ti = (t as NSString).doubleValue
                let date = NSDate(timeIntervalSince1970: ti)
                self.tokenTill = date;
            } else {
                self.tokenTill = nil
            }
            YMMYandexMetrica.reportEvent("APP.ACTION.SIGNIN.SUCCEED", onFailure: nil)
            postNotification(SMStateManagerNotification.SignInSucceed.rawValue, nil)
            if self.pushToken.length() > 0 {
                self.checkPush()
            } else {
                self.registerPush()
            }
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMStateManagerNotification.SignInFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: ["login":login, "password":password],
            success: successBlock,
            failure: failureBlock)
    }
    
    func apiSubscribeToPush() {
        YMMYandexMetrica.reportEvent("APP.EVENT.PUSH.TRY", onFailure: nil)
        
        let urlStr = "\(SMApiHelper.API_PUSH)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            self.subscribedToPush = true
            YMMYandexMetrica.reportEvent("APP.EVENT.PUSH.SUCCEED", onFailure: nil)
            self.registerPush()
        }
        
        let failureBlock = {(error: NSError) -> Void in
            YMMYandexMetrica.reportEvent("APP.EVENT.PUSH.FAILED", onFailure: nil)
        }
        
        var params = [String:AnyObject]()
        
        params["subscribe"] = 1
        params["app_id"] = 2
        
        if self.pushToken.length() > 0 {
            params["device_token"] = self.pushToken
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: params,
            success: successBlock,
            failure: failureBlock)
    }
    
    //MARK - AppiraterDelegate
    
    func appiraterDidDisplayAlert(appirater: Appirater!) {
        YMMYandexMetrica.reportEvent("APP.EVENT.RATE.DIALOG", onFailure: nil)
    }
    
    func appiraterDidDeclineToRate(appirater: Appirater!) {
        YMMYandexMetrica.reportEvent("APP.ACTION.RATE.DECLINE", onFailure: nil)
    }
    
    func appiraterDidOptToRate(appirater: Appirater!) {
        YMMYandexMetrica.reportEvent("APP.ACTION.RATE.ACCEPT", onFailure: nil)
    }
    
    func appiraterDidOptToRemindLater(appirater: Appirater!) {
        YMMYandexMetrica.reportEvent("APP.ACTION.RATE.LATER", onFailure: nil)
    }
}

func vgt(v1: String, v2: String) -> Bool {
    return (v1 as NSString).integerValue > (v2 as NSString).integerValue
}

func vgta(va1: [String], va2: [String], index: Int) -> Bool {
    return vgt(va1[index], va2[index])
}
