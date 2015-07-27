//
//  SMStateManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import KeychainAccess

private enum UserDefaultsKeys: String {
    case PassVersion = "PassVersion"
    
    case Token = "Token"
    case TokenTill = "TokenTill"
    
    case UserLogin = "UserLogin"
    case UserPassowrd = "UserPassowrd"
    
    case PreferedQuality = "PreferedQuality"
    case PreferedTranslation = "PreferedTranslation"
    
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

class SMStateManager: NSObject {
    static let sharedInstance = SMStateManager()
    
    var keychain: Keychain!
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
    
    private(set) var token: String? {
        didSet {
            self.saveKeychainValue(token, key: UserDefaultsKeys.Token.rawValue)
            if let t = self.token {
                SMApiHelper.sharedInstance.setToken(t)
            }
        }
    }
    private(set) var tokenTill: NSDate? {
        didSet {
            self.saveKeychainValue(tokenTill, key: UserDefaultsKeys.TokenTill.rawValue)
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
        
        if let bundleId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String {
            self.keychain = Keychain(service: bundleId)
        }
        
        if let pv = self.getValueForKey(UserDefaultsKeys.PassVersion.rawValue) as? String {
            self.passVersion = pv
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
        
        if let t = self.getKeychainValueForKey(UserDefaultsKeys.Token.rawValue) {
            token = t
            SMApiHelper.sharedInstance.setToken(self.token!)
        }
        if let tt = self.getKeychainAnyObjectForKey(UserDefaultsKeys.TokenTill.rawValue) as? NSDate {
            tokenTill = tt
        }
        
        if let uLogin = self.getKeychainValueForKey(UserDefaultsKeys.UserLogin.rawValue) {
            self.userLogin = uLogin
        }
        if let uPassword = self.getKeychainValueForKey(UserDefaultsKeys.UserPassowrd.rawValue) {
            self.userPassoword = uPassword
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
    
    private func getValueForKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
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
        var result = false
        return result
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
        }
        
        let failureBlock = {(error: NSError) -> Void in
            postNotification(SMStateManagerNotification.SignInFailed.rawValue, error)
        }
        
        SMApiHelper.sharedInstance.performPostRequest(urlStr,
            parameters: ["login":login, "password":password],
            success: successBlock,
            failure: failureBlock)
    }
    
}
