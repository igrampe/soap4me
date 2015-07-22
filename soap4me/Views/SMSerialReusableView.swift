//
//  SMSerialReusableView.swift
//  soap4me
//
//  Created by Sema Belokovsky on 21/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

protocol SMSerialHeaderDelegate: NSObjectProtocol {
    func serialHeaderWatchAction(header: SMSerialReusableView)
    func serialHeaderDescriptionAction(header: SMSerialReusableView)
    func serialHeaderScheduleAction(header: SMSerialReusableView)
}

class SMSerialReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    
    weak var delegate: SMSerialHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func watchAction() {
        self.delegate?.serialHeaderWatchAction(self)
    }
    
    @IBAction func descriptionAction() {
        
    }
    
    @IBAction func scheduleAction() {
        
    }
}
