//
//  SMCatalogViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

enum SMCatalogViewControllerMode: Int {
    case None
    case My
    case All
    case Schedule
}

private enum SerialCategory: String {
    case Unwatched = "unwatched"
    case Watched = "watched"
    case Ended = "ended"
}

class SMCatalogViewController: UIViewController, SMSerialsViewControllerDataSource, SMSerialsViewControllerDelegate {
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var myBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var allBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var scheduleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    
    var serialsMyCtl: SMSerialsViewController!
    var serialsAllCtl: SMSerialsViewController!
    var activeSerialsCtl: SMSerialsViewController?
    var mode: SMCatalogViewControllerMode = .None
    
    var allSerials = [SMSerial]()
    var mySerials = [NSObject:[SMSerial]]()
    var serialsMask: Int = 0b000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "settings"), forState: UIControlState.Normal)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 14)
        settingsButton.frame = CGRectMake(0, 0, 44, 44)
        settingsButton.addTarget(self, action: "settingsAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        self.observe(selector: "apiGetSerialsMySucceed:", name: SMCatalogManagerNotification.ApiGetSerialsMySucceed.rawValue)
        self.observe(selector: "apiGetSerialsAllSucceed:", name: SMCatalogManagerNotification.ApiGetSerialsAllSucceed.rawValue)
        
        self.changeMode(.My)
    }
    
    func settingsAction() {
        if let settingsCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNC") as? UINavigationController {
            self.navigationController?.presentViewController(settingsCtl, animated: true, completion: nil)
        }
    }
    
    private func hasMySerialsForCategory(category: SerialCategory) -> Bool {
        return self.mySerials[category.rawValue]?.count > 0
    }
    
    private func obtainData() {
        
    }
    
    private func reloadUI() {
        self.myBarButtonItem.tintColor = UIColor.whiteColor()
        self.allBarButtonItem.tintColor = UIColor.whiteColor()
        self.scheduleBarButtonItem.tintColor = UIColor.whiteColor()
        switch self.mode {
            case .My: self.myBarButtonItem.tintColor = UIColor.colorWithString("33bbff")
            case .All: self.allBarButtonItem.tintColor = UIColor.colorWithString("33bbff")
            case .Schedule: self.scheduleBarButtonItem.tintColor = UIColor.colorWithString("33bbff")
            default: break
        }
    }
    
    private func reloadData() {
        if (self.mode == .My) {
            self.serialsMask = 0
            self.mySerials[SerialCategory.Unwatched.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyUnwatched().sorted(SMSerial.isOrderedBefore)
            if (self.hasMySerialsForCategory(.Unwatched)) {
                self.serialsMask |= 0b100
            }
            self.mySerials[SerialCategory.Watched.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyWatched().sorted(SMSerial.isOrderedBefore)
            if (self.hasMySerialsForCategory(.Watched)) {
                self.serialsMask |= 0b010
            }
            self.mySerials[SerialCategory.Ended.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyEnded().sorted(SMSerial.isOrderedBefore)
            if (self.hasMySerialsForCategory(.Ended)) {
                self.serialsMask |= 0b001
            }
        } else if (self.mode == .All) {
            self.allSerials = SMCatalogManager.sharedInstance.getSerialsAll().sorted(SMSerial.isOrderedBefore)
        }
    }
    
    private func categoryForSection(section: Int) -> SerialCategory? {
        var category: SerialCategory?
        
        if (self.serialsMask == 0b111) {
            if (section == 0) {
                category = SerialCategory.Unwatched
            } else if (section == 1) {
                category = SerialCategory.Watched
            } else {
                category = SerialCategory.Ended
            }
        } else if (self.serialsMask == 0b110) {
            if (section == 0) {
                category = SerialCategory.Unwatched
            } else {
                category = SerialCategory.Watched
            }
        } else if (self.serialsMask == 0b101) {
            if (section == 0) {
                category = SerialCategory.Unwatched
            } else {
                category = SerialCategory.Ended
            }
        } else if (self.serialsMask == 0b011) {
            if (section == 0) {
                category = SerialCategory.Watched
            } else {
                category = SerialCategory.Ended
            }
        } else if (self.serialsMask == 0b100) {
            category = SerialCategory.Unwatched
        } else if (self.serialsMask == 0b010) {
            category = SerialCategory.Watched
        } else if (self.serialsMask == 0b001) {
            category = SerialCategory.Ended
        }
        
        return category
    }
    
    func changeMode(mode: SMCatalogViewControllerMode) {
        if (self.mode != mode) {
            if let pCtl = self.serialsMyCtl?.parentViewController {
                self.serialsMyCtl.view.removeFromSuperview()
                self.serialsMyCtl.removeFromParentViewController()
            }
            if let pCtl = self.serialsAllCtl?.parentViewController {
                self.serialsAllCtl.view.removeFromSuperview()
                self.serialsAllCtl.removeFromParentViewController()
            }
            self.mode = mode
            self.reloadData()
            switch self.mode {
                case .My: self.showMyCtl()
                case .All: self.showAllCtl()
                case .Schedule: self.showScheduleCtl()
                default: break
            }
            
            self.reloadUI()
        }
    }
    
    func showSerialsCtl(ctl: SMSerialsViewController) {
        ctl.dataSource = self
        ctl.delegate = self
        self.activeSerialsCtl = ctl
        self.showCtl(ctl)
    }

    func showMyCtl() {
        if self.serialsMyCtl == nil {
            self.serialsMyCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
            
        }
        self.serialsMyCtl.mySerials = true
        self.showSerialsCtl(self.serialsMyCtl!)
    }
    
    func showAllCtl() {
        if self.serialsAllCtl == nil {
            self.serialsAllCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
        }
        self.serialsAllCtl.mySerials = false
        self.showSerialsCtl(self.serialsAllCtl!)
    }
    
    func showScheduleCtl() {
        //TODO: schedule
    }
    
    func showCtl(ctl: UIViewController) {
        self.addChildViewController(ctl)
        ctl.view.frame = self.containerView.bounds
        self.containerView.addSubview(ctl.view)
    }
    
    //MARK: Actions
    
    @IBAction func modeAction(sender: UIBarButtonItem) {
        if sender.tag == 0 {
            self.changeMode(.My)
        } else if (sender.tag == 1) {
            self.changeMode(.All)
        }
    }
    
    //MARK: Notifications
    
    func apiGetSerialsMySucceed(notification: NSNotification) {
        self.reloadData()
        self.serialsMyCtl.collectionView.hidden = false
        self.serialsMyCtl.reloadUI()
        self.serialsMyCtl.activityIndicator.stopAnimating()
    }
    
    func apiGetSerialsAllSucceed(notification: NSNotification) {
        self.reloadData()
        self.serialsAllCtl.collectionView.hidden = false
        self.serialsAllCtl.reloadUI()
        self.serialsAllCtl.activityIndicator.stopAnimating()
    }
    
    //MARK: SMSerialsViewControllerDataSource
    
    func numberOfSectionsForSerialsCtl(ctl: SMSerialsViewController) -> Int {
        var result = 0
        if self.mode == .My {
            for m in [0b001, 0b010, 0b100] {
                if (self.serialsMask & m == m) {
                    result++
                }
            }
        } else if self.mode == .All {
            result = 1
        }
        return result
    }
    
    func serialsCtl(ctl: SMSerialsViewController, numberOfObjectsInSection section: Int) -> Int {
        var result = 0
        if self.mode == .My {
            var category: SerialCategory?
            
            if let category = self.categoryForSection(section) {
                result = self.mySerials[category.rawValue]!.count
            }
        } else if self.mode == .All {
            result = self.allSerials.count
        }
        
        return result
    }
    
    func serialsCtl(ctl: SMSerialsViewController, objectAtIndexPath indexPath: NSIndexPath) -> NSObject {
        var object = SMSerial()
        
        if self.mode == .My {
            var category: SerialCategory?
            
            if let category = self.categoryForSection(indexPath.section) {
                object = self.mySerials[category.rawValue]![indexPath.row]
            }
        } else if self.mode == .All {
            object = self.allSerials[indexPath.row]
        }
        
        return object
    }
    
    func serialsCtl(ctl: SMSerialsViewController, titleForSection section: Int) -> String? {
        var title: String?
        if (self.mode == .My) {
            if let category = self.categoryForSection(section) {
                switch category {
                case .Unwatched:
                    title = NSLocalizedString("С новыми эпизодами")
                case .Watched:
                    title = NSLocalizedString("Просмотренные")
                case .Ended:
                    title = NSLocalizedString("Сериал закончен")
                default:
                    break
                }
            }
        } else if (self.mode == .All) {
            title = "All"
        }
        return title
    }
    
    //MARK: SMSerialsViewControllerDelegate
    
    func serialsCtl(ctl: SMSerialsViewController, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var c: SMSerialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SerialVC") as! SMSerialViewController
        var object = SMSerial()
        
        if self.mode == .My {
            var category: SerialCategory?
            
            if let category = self.categoryForSection(indexPath.section) {
                object = self.mySerials[category.rawValue]![indexPath.row]
            }
        } else if self.mode == .All {
            object = self.allSerials[indexPath.row]
        }
        c.sid = object.sid
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    func serialsCtlNeedObtainData(ctl: SMSerialsViewController) {
        switch self.mode {
            case .My: SMCatalogManager.sharedInstance.apiGetSerialsMy()
            case .All: SMCatalogManager.sharedInstance.apiGetSerialsAll()
            default: break
        }
    }
}
