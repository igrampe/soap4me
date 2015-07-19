//
//  SMStateManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

private enum UserDefaultsKeys: String {
    case Token = "Token"
    case TokenTill = "TokenTill"
    
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
    
//    var stringVale: String {
//        switch self {
//        case .SignInSucceed: return "SMStateManagerNotification.\(SignInSucceed)";
//        case .SignInFailed: return "SMStateManagerNotification.\(SignInFailed)";
//        }
//    }
    
}

class SMStateManager: NSObject {
    static let sharedInstance = SMStateManager()
    
    override init() {
        if let t = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.Token.rawValue) {
            token = t
            SMApiHelper.sharedInstance.setToken(self.token!)
        }
        if let tt = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKeys.TokenTill.rawValue) as? NSDate  {
            tokenTill = tt
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
    
    private func saveValue(value: AnyObject?, key: String) {
        if let v: AnyObject = value {
            NSUserDefaults.standardUserDefaults().setValue(v, forKey: key)
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
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
    
    //MARK: API
    func signIn(login: String, password: String) {
        
        let urlStr = "\(SMApiHelper.sharedInstance.API_LOGIN)"
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
