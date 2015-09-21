//
//  SMSettingsCellAction.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMSettingsCellAction: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    func commonInit() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.blackColor()
        
        self.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        self.textLabel?.textAlignment = NSTextAlignment.Center
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.textColor = UIColor(hex: "33bbff")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
