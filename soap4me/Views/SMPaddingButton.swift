//
//  SMPaddingButton.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

@IBDesignable class SMPaddingButton: UIButton {
    
    override func intrinsicContentSize() -> CGSize {
        var size: CGSize = super.intrinsicContentSize()
        size.width += self.titleEdgeInsets.left + self.titleEdgeInsets.right;
        size.height += self.titleEdgeInsets.top + self.titleEdgeInsets.bottom;
        return size
    }
}
