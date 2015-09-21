//
//  APLPluralize.swift
//  soap4me
//
//  Created by Semyon Belokovsky on 21/09/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

extension NSNumber
{
    func pluralizedStringWithOne(one: String, few: String, many: String) -> String
    {
        let value = self.integerValue;
        var ret = String(format: "%ld ", value)
        if (value % 10 == 1 && value != 11) {
            ret.appendContentsOf(one)
        }
        else if (value % 10 >= 2 && value % 10 <= 4 && (value % 100 < 12 || value % 100 > 14)) {
            ret.appendContentsOf(few)
        }
        else {
            ret.appendContentsOf(many)
        }
        return ret
    }
}
