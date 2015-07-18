//
//  NSNotification+APL.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import Foundation

extension NSObject {
    func observe(selector aSelector: Selector, name aName: String?) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: aSelector, name: aName, object: nil)
    }
    
    func stopObserve() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

func postNotification(name: String, object: AnyObject?) {
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
}