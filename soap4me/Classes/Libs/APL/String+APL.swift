//
//  String+APL.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import Foundation

extension String {
    func length() -> Int {
        return count(self)
    }
}

func NSLocalizedString(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}