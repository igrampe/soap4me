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
    
    var serialsCtl: SMSerialsViewController!
    var mode: SMCatalogViewControllerMode = .My
    
    var mySerials = [NSObject:[SMSerial]]()
    var serialsMask: Int = 0b000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
        self.observe(selector: "apiGetSerialsMySucceed:", name: SMCatalogManagerNotification.ApiGetSerialsMySucceed.rawValue)
        self.showMyCtl()
    }
    
    private func hasMySerialsForCategory(category: SerialCategory) -> Bool {
        return self.mySerials[category.rawValue]?.count > 0
    }
    
    func isOrderedBeforeAlphabetcally(obj1: SMSerial, obj2: SMSerial) -> Bool {
        var result = (obj1.valueForKey("title_ru") as! String).caseInsensitiveCompare((obj2.valueForKey("title_ru") as! String))
        if result == NSComparisonResult.OrderedAscending || result == NSComparisonResult.OrderedSame {
            return true
        } else {
            return false
        }
    }
    
    func reloadData() {
        if (self.mode == .My) {
            self.serialsMask = 0
            self.mySerials[SerialCategory.Unwatched.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyUnwatched().sorted(self.isOrderedBeforeAlphabetcally)
            if (self.hasMySerialsForCategory(.Unwatched)) {
                self.serialsMask |= 0b100
            }
            self.mySerials[SerialCategory.Watched.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyWatched().sorted(self.isOrderedBeforeAlphabetcally)
            if (self.hasMySerialsForCategory(.Watched)) {
                self.serialsMask |= 0b010
            }
            self.mySerials[SerialCategory.Ended.rawValue] = SMCatalogManager.sharedInstance.getSerialsMyEnded().sorted(self.isOrderedBeforeAlphabetcally)
            if (self.hasMySerialsForCategory(.Ended)) {
                self.serialsMask |= 0b001
            }
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
            self.serialsCtl.dataSource = self
            self.serialsCtl.delegate = self
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
    
    //MARK: Notifications
    
    func apiGetSerialsMySucceed(notification: NSNotification) {
        self.reloadData()
        self.serialsCtl.collectionView.hidden = false
        self.serialsCtl.reloadUI()
        self.serialsCtl.activityIndicator.stopAnimating()
    }
    
    //MARK: SMSerialsViewControllerDataSource
    
    func numberOfSectionsForSerialsCtl(ctl: SMSerialsViewController) -> Int {
        var result = 0
        for m in [0b001, 0b010, 0b100] {
            if (self.serialsMask & m == m) {
                result++
            }
        }
        return result
    }
    
    func serialsCtl(ctl: SMSerialsViewController, numberOfObjectsInSection section: Int) -> Int {
        var result = 0
        var category: SerialCategory?
        
        if let category = self.categoryForSection(section) {
            result = self.mySerials[category.rawValue]!.count
        }
        
        return result
    }
    
    func serialsCtl(ctl: SMSerialsViewController, objectAtIndexPath indexPath: NSIndexPath) -> NSObject {
        var object = SMSerial()
        var category: SerialCategory?
        
        if let category = self.categoryForSection(indexPath.section) {
            object = self.mySerials[category.rawValue]![indexPath.row]
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
        }
        return title
    }
    
    //MARK: SMSerialsViewControllerDelegate
    
    func serialsCtl(ctl: SMSerialsViewController, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var c = self.storyboard?.instantiateViewControllerWithIdentifier("SeasonsVC") as! UIViewController
        self.navigationController?.pushViewController(c, animated: true)
    }
}
