//
//  SMSettingsCellBool.swift
//  soap4me
//
//  Created by Sema Belokovsky on 01/08/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

protocol SMSettingsCellBoolDelegate: NSObjectProtocol {
    func boolSettingsCellSwitchAction(cell: SMSettingsCellBool)
}

class SMSettingsCellBool: UITableViewCell {

    var valueSwitch: UISwitch!
    weak var delegate: SMSettingsCellBoolDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    func commonInit() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.blackColor()
        
        self.textLabel?.font = UIFont.boldSystemFontOfSize(17)
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.textColor = UIColor.whiteColor()
        
        self.valueSwitch = UISwitch()
        self.valueSwitch.tintColor = UIColor(hex: "33bbff")
        self.valueSwitch.onTintColor = UIColor(hex: "33bbff")
        self.valueSwitch.addTarget(self, action: "switchAction", forControlEvents: UIControlEvents.ValueChanged)
        self.contentView.addSubview(self.valueSwitch)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.valueSwitch.frame = CGRectMake(self.bounds.size.width-8-51, (self.bounds.size.height-31)/2, 51, 31)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func switchAction() {
        self.delegate?.boolSettingsCellSwitchAction(self)
    }
}
