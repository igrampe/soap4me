//
//  SMScheduleHeader.swift
//  soap4me
//
//  Created by Sema Belokovsky on 27/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMScheduleHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    func commonInit() {
        
    }
}
