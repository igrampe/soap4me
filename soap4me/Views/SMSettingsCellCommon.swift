//
//  SMSettingsCellCommon.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMSettingsCellCommon: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.blackColor()
        
        self.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.textColor = UIColor.whiteColor()
        
        self.detailTextLabel?.backgroundColor = UIColor.clearColor()
        self.detailTextLabel?.textColor = UIColor.whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
