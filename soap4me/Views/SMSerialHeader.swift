//
//  SMSerialHeader.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

protocol SMSerialHeaderDelegate: NSObjectProtocol {
    func serialHeaderWatchAction(header: SMSerialHeader)
    
    func serialHeaderSeasonsAction(header: SMSerialHeader)
    func serialHeaderDescriptionAction(header: SMSerialHeader)
    func serialHeaderScheduleAction(header: SMSerialHeader)
}

class SMSerialHeader: UIView {
    @IBOutlet weak var imageView: SMAsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var watchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var watchButton: SMPaddingButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegate: SMSerialHeaderDelegate?
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    @IBAction func watchAction() {
        self.delegate?.serialHeaderWatchAction(self)
    }
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        switch self.segmentControl.selectedSegmentIndex {
            case 0: self.delegate?.serialHeaderSeasonsAction(self)
            case 1: self.delegate?.serialHeaderDescriptionAction(self)
            case 2: self.delegate?.serialHeaderScheduleAction(self)
            default: break
        }
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib("SMSerialHeader")
        self.view.frame = self.bounds
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.addSubview(self.view)
        
        self.watchButton.layer.cornerRadius = 5
        self.watchButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.watchButton.layer.borderWidth = 1
        self.watchButton.layer.masksToBounds = true
        
        self.segmentControl.setTitle(NSLocalizedString("Серии"), forSegmentAtIndex: 0)
        self.segmentControl.setTitle(NSLocalizedString("Описание"), forSegmentAtIndex: 1)
        self.segmentControl.setTitle(NSLocalizedString("Расписание"), forSegmentAtIndex: 2)
    }
    
    func loadViewFromNib(nibName: String) -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}