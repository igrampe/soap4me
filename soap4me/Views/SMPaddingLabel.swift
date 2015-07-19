//
//  SMPaddingLabel.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMPaddingLabel: UILabel {

    var edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, self.edgeInsets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size: CGSize = super.intrinsicContentSize()
        size.width += self.edgeInsets.left + self.edgeInsets.right;
        size.height += self.edgeInsets.top + self.edgeInsets.bottom;
        return size
    }
}
