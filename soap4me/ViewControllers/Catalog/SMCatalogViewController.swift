//
//  SMCatalogViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

enum SMCatalogViewControllerMode: Int {
    case My
    case All
    case Schedule
}

class SMCatalogViewController: UIViewController {
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var myBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var allBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var scheduleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    
    var serialsCtl: SMSerialsViewController!
    var mode: SMCatalogViewControllerMode = .My
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showMyCtl()
    }
    
    func changeMode(mode: SMCatalogViewControllerMode) {
        self.mode = mode
        switch self.mode {
        case .My:
            self.showMyCtl()
        case .All:
            self.showAllCtl()
        case .Schedule:
            self.showScheduleCtl()
            break
        }
    }

    func showMyCtl() {
        if let sCtl = self.serialsCtl {
            self.showCtl(sCtl)
        } else {
            self.serialsCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
            self.showCtl(self.serialsCtl!)
        }
    }
    
    func showAllCtl() {
        if let sCtl = self.serialsCtl {
            self.showCtl(sCtl)
        } else {
            self.serialsCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
            self.showCtl(self.serialsCtl!)
        }
    }
    
    func showScheduleCtl() {
        if let sCtl = self.serialsCtl {
            self.showCtl(sCtl)
        } else {
            self.serialsCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
            self.showCtl(self.serialsCtl!)
        }
    }
    
    func showCtl(ctl: UIViewController) {
        self.addChildViewController(ctl)
        ctl.view.frame = self.containerView.bounds
        self.containerView.addSubview(ctl.view)
    }
}
