//
//  SMCatalogManager.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

class SMCatalogManager: NSObject {
    
    static let sharedInstance = SMCatalogManager()
    
    func apiGetSerials() {
        
        let urlStr = "\(SMApiHelper.sharedInstance.API_SERIALS)"
        let successBlock = {(responseObject: [String:AnyObject]) -> Void in
            
        }
        
        let failureBlock = {(error: NSError) -> Void in
            
        }
        
        SMApiHelper.sharedInstance.performGetRequest(urlStr,
            success: successBlock,
            failure: failureBlock)
    }
    
    func getSerialsMy() -> [SMSerial] {
        return [SMSerial]()
    }
    
    func getSerialsAll() -> [SMSerial] {
        return [SMSerial]()
    }
}
