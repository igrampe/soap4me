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
    
    func pRequest(method: Alamofire.Method,
        urlStr: String,
        parameters: [String:AnyObject]?,
        success: APLApiSuccessBlock?,
        failure: APLApiFailureBlock?) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(method, urlStr, parameters: parameters, encoding: .URL)
            .responseJSON { (_, _, JSON, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let err = error {
                    if let fb = failure {
                        fb(err)
                    }
                } else {
                    if let sb = success {
                        if let responseObject: AnyObject = JSON {
                            sb(responseObject)
                        } else {
                            let responseObject = [String: AnyObject]()
                            sb(responseObject)
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
}