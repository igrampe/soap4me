//
//  APLApiHelper.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import Alamofire

typealias APLApiSuccessBlock = (AnyObject) -> Void
typealias APLApiFailureBlock = (NSError) -> Void


class APLApiHelper: NSObject {
    var sharedHeaders = [String: String]()
    var networkActivityIndicatorCount = 0
    
    func pRequest(method: Alamofire.Method,
        urlStr: String,
        parameters: [String:AnyObject]?,
        success: APLApiSuccessBlock?,
        failure: APLApiFailureBlock?)
    {
        self.networkActivityIndicatorRetain()
        Alamofire.Manager.sharedInstance.request(method, urlStr,
            parameters: parameters, 
            encoding: .URL,
            headers: self.sharedHeaders)
            .responseJSON { (request, response, result) in
                self.networkActivityIndicatorRelease()
                if (result.isSuccess)
                {
                    if let sb = success
                    {
                        if let responseObject: AnyObject = result.value
                        {
                            sb(responseObject)
                        } else
                        {
                            let responseObject = [String: AnyObject]()
                            sb(responseObject)
                        }
                    }
                } else
                {
                    if let err: NSError = result.error as? NSError
                    {
                        if let fb = failure
                        {
                            fb(err)
                        }
                    }
                }
        }
    }
    
    func pPostRequest(urlStr: String,
        parameters: [String:AnyObject]?,
        success: APLApiSuccessBlock?,
        failure: APLApiFailureBlock?) {
            
        self.pRequest(.POST,
            urlStr: urlStr,
            parameters: parameters,
            success: success,
            failure: failure)
    }
    
    func pGetRequest(urlStr: String,
        parameters: [String:AnyObject]?,
        success: APLApiSuccessBlock?,
        failure: APLApiFailureBlock?) {
            
        self.pRequest(.GET,
            urlStr: urlStr,
            parameters: parameters,
            success: success,
            failure: failure)
    }
    
    func networkActivityIndicatorRetain() {
        self.networkActivityIndicatorCount++
        self.checkActivityIndicator()
    }
    
    func networkActivityIndicatorRelease() {
        self.networkActivityIndicatorCount--
        self.checkActivityIndicator()
    }
    
    func checkActivityIndicator() {
        if self.networkActivityIndicatorCount > 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}