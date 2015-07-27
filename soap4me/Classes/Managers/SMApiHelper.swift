//
//  APLApiHelper.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Alamofire

typealias SMApiSuccessBlock = ([String: AnyObject]) -> Void
typealias SMApiFailureBlock = (NSError) -> Void

let APP_DOMAIN: String = "APP_DOMAIN"
let HOST: String = "soap4.me"
let HOST_URL: String = "https://\(HOST)"
let API_URL: String = "\(HOST_URL)/api"

class SMApiHelper: APLApiHelper {
    static let sharedInstance = SMApiHelper()
    
    override init() {
        super.init()
        
        self.setHTTPHeader("xbmc for soap", forKey: "User-Agent")
    }
    
    func setHTTPHeader(header: AnyObject, forKey key: NSObject) {
        var headers = [NSObject: AnyObject]()
        if (Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders != nil) {
            headers = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders!
        }
        headers[key] = header
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = headers
    }
    
    func setToken(token: String) {
        self.setHTTPHeader(token, forKey: "x-api-token")
    }
    
    //MARK: API methods names
    static let ASSET_COVER_SERIAL_BIG: String = "\(HOST_URL)/assets/covers/soap/big/%d.jpg"
    static let ASSET_COVER_SEASON_BIG: String = "\(HOST_URL)/assets/covers/season/big/%d.jpg"
    
    static let API_LOGIN: String = "\(HOST_URL)/login"
    
    static let API_SERIALS: String = "\(API_URL)/soap"
    static let API_SERIALS_MY: String = "\(API_URL)/soap/my"
    static let API_SERIALS_ALL: String = "\(API_URL)/soap"
    
    static let API_EPISODES: String = "\(API_URL)/episodes"
    
    static let API_SERIAL_META: String = "\(API_URL)/soap/description"
    static let API_SERIAL_MARK_WATCHING: String = "\(API_URL)/soap/watch"
    static let API_SERIAL_MARK_NOT_WATCHING: String = "\(API_URL)/soap/unwatch"
    
    static let API_EPISODE_TOGGLE_WATCHED: String = "\(HOST_URL)/callback"
    static let API_EPISODE_LINK_INFO: String = "\(HOST_URL)/callback"
    
    //MARK: Methods    
    func performPostRequest(urlStr: String, parameters: [String:AnyObject]?, success: SMApiSuccessBlock?, failure: APLApiFailureBlock?) {
        
        self.performRequest(Alamofire.Method.POST, urlStr: urlStr, parameters: parameters, success: success, failure: failure)
    }
    
    func performGetRequest(urlStr: String, parameters: [String:AnyObject]?, success: SMApiSuccessBlock?, failure: APLApiFailureBlock?) {
        self.performRequest(Alamofire.Method.GET, urlStr: urlStr, parameters: parameters, success: success, failure: failure)
    }
    
    func performGetRequest(urlStr: String, success: SMApiSuccessBlock?, failure: APLApiFailureBlock?) {
        self.performGetRequest(urlStr, parameters: nil, success: success, failure: failure)
    }
    
    //MARK: -Helpers
    func performRequest(method: Alamofire.Method, urlStr: String, parameters: [String:AnyObject]?, success: SMApiSuccessBlock?, failure: APLApiFailureBlock?) {
        
        let fb = self.buildFailureBlock(failure)
        let sb = self.buildSuccessBlock(success, failure: fb)
        super.pRequest(method, urlStr: urlStr, parameters: parameters, success: sb, failure: fb)
    }
    
    func buildSuccessBlock(success: SMApiSuccessBlock?, failure: SMApiFailureBlock?) -> APLApiSuccessBlock {
        let sb: APLApiSuccessBlock = {(responseObject: AnyObject) -> Void in
            var responseDict: [String: AnyObject] = ["ok": 0]
            
            if let ro = responseObject as? [String: AnyObject] {
                responseDict = ro
            } else if let ra = responseObject as? [AnyObject] {
                responseDict["objects"] = ra
                responseDict["ok"] = 1
            }
            
            var ok: Bool = false
            if let o = responseDict["ok"] as? Bool {
                ok = o
            } else {
                var dict = responseDict
                responseDict.removeAll(keepCapacity: false)
                ok = true
                responseDict["ok"] = ok
                responseDict["object"] = dict
            }
            if ok {
                if let isb = success {
                    isb(responseDict)
                }
            } else {
                let desc = responseDict["error"] as! String?
                var userInfo: [NSObject : AnyObject]
                var code = -1
                if let v = desc {
                    if v == "wrong token" {
                        code = 1
                        userInfo = ["NSLocalizedDescription":NSLocalizedString("Неверный токен авторизации")]
                    } else {
                        userInfo = ["NSLocalizedDescription":v]
                    }
                } else {
                    userInfo = ["NSLocalizedDescription":NSLocalizedString("Неизвестная ошибка", comment: "")]
                }
                let error = NSError(domain: APP_DOMAIN, code: 1, userInfo: userInfo)
                if let fb = failure {
                    fb(error)
                }
            }
        }
        return sb
    }
    
    func buildFailureBlock(failure: SMApiFailureBlock?) -> APLApiFailureBlock {
        let fb: APLApiFailureBlock = {(error: NSError) -> Void in
            var exception = NSException(name: "API", reason: error.description, userInfo: error.userInfo)
            YMMYandexMetrica.reportError("API.ERROR", exception: exception, onFailure: nil)
            if error.code == 1 {
                SMStateManager.sharedInstance.clearState()
            }
            if let f = failure {
                f(error)
            }
        }
        return fb
    }
    
    static func makeHash(token: String, eid: Int, hash: String, sid: Int) -> String {
        var h = "\(token)\(eid)\(sid)\(hash)".md5()
        return h
    }
    
    static func makeLink(server: String, token: String, eid: Int, sid: Int, hash: String) -> String {
        let h = self.makeHash(token, eid: eid, hash: hash, sid: sid)
        var link = String(format: "https://%@.%@/%@/%d/%@", server, HOST, token, eid, h)
        return link
    }
}