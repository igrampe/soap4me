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

class SMCatalogViewController: UIViewController, SMSerialsViewControllerDataSource, SMSerialsViewControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var myBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var allBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var scheduleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    
    var segmentedControl: UISegmentedControl!
    
    var serialsMyCtl: SMSerialsViewController!
    var serialsAllCtl: SMSerialsViewController!
    var scheduleCtl: SMScheduleViewController!
    var activeSerialsCtl: SMSerialsViewController?
    var searchItem: UIBarButtonItem!
    var playItem: UIBarButtonItem!
    
    var searchBar: UISearchBar!
    var rightSpaceItem: UIBarButtonItem!
    
    var mode: SMCatalogViewControllerMode = .None
    
    var allSerials = [SMSerial]()
    var mySerials = [NSObject:[SMSerial]]()
    var serialsMask: Int = 0b000
    var searchActive: Bool = false
    var searchResults = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar = UISearchBar()
        self.searchBar.backgroundColor = UIColor.clearColor()
        self.searchBar.backgroundImage = UIImage(named: "black")
        self.searchBar.delegate = self
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width-48, 30)
        self.searchBar.barStyle = UIBarStyle.Black
        self.searchBar.placeholder = NSLocalizedString("Поиск")
        self.searchBar.tintColor = UIColor.whiteColor()
        
        var settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "settings"), forState: UIControlState.Normal)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 7+3, left: 0, bottom: 7+3, right: 0)
        settingsButton.frame = CGRectMake(0, 0, 24, 44)
        settingsButton.addTarget(self, action: "settingsAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        var playButton = UIButton()
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        playButton.imageEdgeInsets = UIEdgeInsets(top: 7+3, left: 6, bottom: 7+3, right: 0)
        playButton.frame = CGRectMake(0, 0, 24, 44)
        playButton.addTarget(self, action: "playAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.playItem = UIBarButtonItem(customView: playButton)
        self.navigationItem.rightBarButtonItem = self.playItem
        
        var rightSpace = UIButton()
        rightSpace.setImage(UIImage(named: "clear"), forState: UIControlState.Normal)
        rightSpace.frame = CGRectMake(0, 0, 24, 44)
        self.rightSpaceItem = UIBarButtonItem(customView: rightSpace)
        
        self.segmentedControl = UISegmentedControl()
        self.segmentedControl.tintColor = UIColor.whiteColor()
        self.segmentedControl.insertSegmentWithTitle(NSLocalizedString("Мои"), atIndex: 0, animated: false)
        self.segmentedControl.insertSegmentWithTitle(NSLocalizedString("Все"), atIndex: 1, animated: false)
        self.segmentedControl.setWidth(100, forSegmentAtIndex: 0)
        self.segmentedControl.setWidth(100, forSegmentAtIndex: 1)
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.sizeToFit()
        self.segmentedControl.addTarget(self, action: "changeScheduleMode", forControlEvents: UIControlEvents.ValueChanged)
        
        self.observe(selector: "apiGetSerialsMySucceed:", name: SMCatalogManagerNotification.ApiGetSerialsMySucceed.rawValue)
        self.observe(selector: "apiGetSerialsAllSucceed:", name: SMCatalogManagerNotification.ApiGetSerialsAllSucceed.rawValue)
        
        self.changeMode(.My)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.mode == .My {
            if SMStateManager.sharedInstance.lastPlayingEid != 0 {
                self.navigationItem.rightBarButtonItem = self.playItem
            }
        }
    }
    
    func settingsAction() {
        YMMYandexMetrica.reportEvent("APP.ACTION.SETTINGS", onFailure: nil)
        if let settingsCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNC") as? UINavigationController {
            self.navigationController?.presentViewController(settingsCtl, animated: true, completion: nil)
        }
    }
    
    func playAction() {
        if SMStateManager.sharedInstance.lastPlayingEid != 0 {
            if let episode = SMCatalogManager.sharedInstance.getEpisodeWithEid(SMStateManager.sharedInstance.lastPlayingEid) {
                if let progress = SMCatalogManager.sharedInstance.getEpisodeProgress(forSeasonId: episode.season_id, episodeNumber: episode.episode) {
                    var c: SMPlayerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PlayerVC") as! SMPlayerViewController
                    c.eid = episode.eid
                    c.hsh = episode.hsh
                    c.sid = episode.sid
                    c.episode = episode.episode
                    c.season_id = episode.season_id
                    c.startPosition = progress.progress
                    self.navigationController?.presentViewController(c, animated: true, completion: nil)
                }
            }
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
    
    private func filerData(string: String) {
        searchResults.removeAll(keepCapacity: false)
        for var i = 0; i < self.allSerials.count; i++ {
            var serial = self.allSerials[i]
            var shouldAdd: Bool = ((serial.title_ru.lowercaseString as NSString).rangeOfString(string.lowercaseString).location != NSNotFound)
            shouldAdd = shouldAdd || ((serial.title.lowercaseString as NSString).rangeOfString(string.lowercaseString).location != NSNotFound)
            shouldAdd = shouldAdd || string.length() == 0
            if (shouldAdd) {
                searchResults.append(i)
            }
        }
        self.serialsAllCtl?.reloadUI()
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
            if self.searchActive {
                self.filerData(self.searchBar.text)
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
        if (self.mode != mode) {
            if let pCtl = self.serialsMyCtl?.parentViewController {
                self.serialsMyCtl.view.removeFromSuperview()
                self.serialsMyCtl.removeFromParentViewController()
            }
            if let pCtl = self.serialsAllCtl?.parentViewController {
                self.serialsAllCtl.view.removeFromSuperview()
                self.serialsAllCtl.removeFromParentViewController()
            }
            if let pCtl = self.scheduleCtl?.parentViewController {
                self.scheduleCtl.view.removeFromSuperview()
                self.scheduleCtl.removeFromParentViewController()
            }
            if let pV = self.segmentedControl.superview {
                self.navigationItem.titleView = nil
            }
            if let pV = self.searchBar.superview {
                self.navigationItem.titleView = nil
            }
            if self.navigationItem.rightBarButtonItem != nil {
               self.navigationItem.rightBarButtonItem = nil
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
    
    func changeScheduleMode() {
        self.scheduleCtl.setMode(SMScheduleMode(rawValue: self.segmentedControl.selectedSegmentIndex)!)
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
        if SMStateManager.sharedInstance.lastPlayingEid != 0 {
            self.navigationItem.rightBarButtonItem = self.playItem
        }
        self.serialsMyCtl.mySerials = true
        self.showSerialsCtl(self.serialsMyCtl!)
    }
    
    func showAllCtl() {
        if self.serialsAllCtl == nil {
            self.serialsAllCtl = self.storyboard?.instantiateViewControllerWithIdentifier("SerialsVC") as! SMSerialsViewController
        }
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.rightBarButtonItem = self.rightSpaceItem
        self.serialsAllCtl.mySerials = false
        self.showSerialsCtl(self.serialsAllCtl!)
    }
    
    func showScheduleCtl() {
        if self.scheduleCtl == nil {
            self.scheduleCtl = self.storyboard?.instantiateViewControllerWithIdentifier("ScheduleVC") as! SMScheduleViewController
        }
        self.navigationItem.titleView = self.segmentedControl
        self.showCtl(self.scheduleCtl!)
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
        } else if (sender.tag == 2) {
            self.changeMode(.Schedule)
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
            if (self.searchActive) {
                result = self.searchResults.count
            } else {
                result = self.allSerials.count
            }
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
            if (self.searchActive) {
                object = self.allSerials[searchResults[indexPath.row]]
            } else {
                object = self.allSerials[indexPath.row]
            }
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
            if (self.searchActive) {
                object = self.allSerials[searchResults[indexPath.row]]
                self.searchBar.resignFirstResponder()
            } else {
                object = self.allSerials[indexPath.row]
            }
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
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        self.navigationItem.rightBarButtonItem = self.rightSpaceItem
        self.searchActive = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.navigationItem.rightBarButtonItem = self.rightSpaceItem
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filerData(searchText)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.filerData(searchBar.text)
        self.searchActive = true
        searchBar.showsCancelButton = true
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = self.rightSpaceItem
    }
}
