//
//  ViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 17/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import SVProgressHUD

public enum SMRootViewControllerNotification: String {
    case HideCtl = "HideCtl"
}

class SMRootViewController: UIViewController, SignInViewControllerProtocol {
    var signInVC: SMSignInViewController?
    var catalogNC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
        SVProgressHUD.setForegroundColor(UIColor.blackColor())
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Gradient)
        
        self.observe(selector: "hideCtlNotification:", name: SMRootViewControllerNotification.HideCtl.rawValue)
        self.observe(selector: "handleClearState:", name: SMStateManagerNotification.StateCleared.rawValue)
        
        
        if (SMStateManager.sharedInstance.hasValidToken()) {
            self.showCatalogCtl()
        } else {
            self.showSignInVC()
        }
    }
    
    func showCtl(ctl: UIViewController?) {
        if let c = ctl {
            self.addChildViewController(c)
            self.view.addSubview(c.view)
        }
    }
    
    func hideCtl(ctl: UIViewController?) {
        if let c = ctl {
            if c.parentViewController == self && c.view.superview == self.view {
                c.view.removeFromSuperview()
                c.removeFromParentViewController()
            }
        }
    }

    func showSignInVC() {
        if self.signInVC == nil {
            self.signInVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignInVC") as? SMSignInViewController
            self.signInVC?.delegate = self
        }
        self.showCtl(self.signInVC!)
    }
    
    func showCatalogCtl() {
        if self.catalogNC == nil {
            self.catalogNC = self.storyboard?.instantiateViewControllerWithIdentifier("CatalogNC") as? UINavigationController
        }
        self.showCtl(self.catalogNC!)
    }
    
    //MARK: Notifications
    
    func hideCtlNotification(notification: NSNotification) {
        if let ctl = notification.object as? UIViewController {
            self.hideCtl(ctl)
        }
    }
    
    func handleClearState(notification: NSNotification) {
        self.hideCtl(self.catalogNC)
        if self.signInVC?.parentViewController == nil {
            self.showSignInVC()
        }
    }
    
    //MARK: SignInViewControllerProtocol
    
    func signInSucceed() {
        self.hideCtl(self.signInVC)
        self.showCatalogCtl()        
    }
}

