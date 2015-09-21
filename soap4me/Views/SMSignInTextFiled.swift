//
//  SMSignInTextFiled.swift
//  soap4me
//
//  Created by Sema Belokovsky on 18/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

class SMSignInTextFiled: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.borderStyle = UITextBorderStyle.None
        self.tintColor = UIColor.whiteColor()
        self.underlineView = UIView()
        self.underlineView.backgroundColor = UIColor.colorWithString("AAA")
        self.addSubview(self.underlineView)
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.underlineView.frame = CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)
    }
    
    func configure() {
        if let str = self.placeholder {
            let aStr: NSMutableAttributedString = NSMutableAttributedString(string: str)            
            aStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, str.length()))
            self.attributedPlaceholder = aStr
        }
    }
    
    private var underlineView: UIView!
}