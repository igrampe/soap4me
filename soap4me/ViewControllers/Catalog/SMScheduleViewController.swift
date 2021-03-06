//
//  SMScheduleViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 27/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

enum SMScheduleMode: Int {
    case My = 0
    case All = 1
}

class SMScheduleViewController: UIViewController {

    private let CellIdentifier = "CellIdentifier"
    private let HeaderIdentifier = "HeaderIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var scheduleItems = [Int: [SMScheduleItem]]()
    var scheduleKeys = [Int]()
    var scheduleMode: SMScheduleMode = .My
    var scheduleRequested = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
//        var v = UIView()
//        v.backgroundColor = UIColor.clearColor()
//        self.tableView.backgroundView = v
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.frame = CGRectZero
        self.refreshControl?.backgroundColor = UIColor.blackColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "obtainData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.endRefreshing()
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88
        
        self.tableView.registerNib(UINib(nibName: "SMScheduleItemCell", bundle: nil), forCellReuseIdentifier: self.CellIdentifier)
        self.tableView.registerNib(UINib(nibName: "SMScheduleHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderIdentifier)
        self.obtainData()
        self.layoutOffset()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.observe(selector: "didRotateNotification", name: UIDeviceOrientationDidChangeNotification)
        self.observe(selector: "apiGetScheduleSucceed:", name: SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue)
        self.observe(selector: "apiGetScheduleFailed:", name: SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue)
        self.reloadData()
        self.reloadUI()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.stopObserve()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didRotateNotification() {
        self.tableView.reloadData()
        self.layoutOffset()
    }
    
    func layoutOffset() {
        var shouldScroll = false
        if (self.tableView.contentOffset.y == -self.tableView.contentInset.top) {
            shouldScroll = true
        }
        
        var offset: CGFloat = 0
        if let _ = self.navigationController {
            offset = 0//44+20
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(offset, 0, self.tableView.contentInset.bottom, 0)
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        
        if shouldScroll {
            self.tableView.setContentOffset(CGPointMake(0, -self.tableView.contentInset.top), animated: false)
        }
    }
    
    func setMode(mode: SMScheduleMode) {
        self.scheduleMode = mode
        self.reloadData()
        self.reloadUI()
        if self.scheduleRequested & 0b10 == 0 {
            self.obtainData()
            self.scheduleRequested = self.scheduleRequested|0b10
        }
    }
    
    func obtainData() {
        switch self.scheduleMode {
            case .My: SMCatalogManager.sharedInstance.apiGetScheduleMy()
            case .All: SMCatalogManager.sharedInstance.apiGetScheduleAll()
        }
    }
    
    func reloadData() {
        self.scheduleItems.removeAll(keepCapacity: false)
        self.scheduleKeys.removeAll(keepCapacity: false)
        var itms: [SMScheduleItem]
        
        switch self.scheduleMode {
            case .My: itms = SMCatalogManager.sharedInstance.getScheduleItemsMy()
            case .All: itms = SMCatalogManager.sharedInstance.getScheduleItemsAll()
        }
        
        for it in itms {
            let tms = self.dayTmsForTms(it.date)
            let arr = self.scheduleItems[tms]
            if arr == nil {
                self.scheduleItems[tms] = [SMScheduleItem]()
            }
            self.scheduleItems[tms]?.append(it)
        }
        
        self.scheduleKeys.appendContentsOf(Array(scheduleItems.keys))
        self.scheduleKeys.sortInPlace { (obj1: Int, obj2: Int) -> Bool in
            return obj1 < obj2
        }
    }
    
    func reloadUI() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var result = 0
        result = self.scheduleKeys.count
        return result
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if let items = self.scheduleItems[self.scheduleKeys[section]] {
            result = items.count
        }
        return result
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! SMScheduleItemCell
        
        
        if let items = self.scheduleItems[self.scheduleKeys[indexPath.section]] {
            let item: SMScheduleItem = items[indexPath.row]
            let str = String(format: "%@. %@ %d, %@ %d.\n%@", item.serial_name, NSLocalizedString("Сезон"), item.season_number, NSLocalizedString("cерия"), item.episode_number, item.title)
            let aStr = NSMutableAttributedString(string: str)
            var range = NSMakeRange(0, str.length())
            aStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
            aStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: range)
            range = NSMakeRange(0, item.serial_name.length())
            aStr.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: "33bbff"), range: range)
            aStr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(17), range: range)
            cell.titleLabel.attributedText = aStr
        }

        return cell
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderIdentifier) as? SMScheduleHeader
        
        header?.titleLabel.text = self.titleForTms(self.scheduleKeys[section])
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let items = self.scheduleItems[self.scheduleKeys[indexPath.section]] {
            let item: SMScheduleItem = items[indexPath.row]
            let c: SMSerialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SerialVC") as! SMSerialViewController
            
            c.sid = item.sid
            self.navigationController?.pushViewController(c, animated: true)
        }
    }
    
    //MARK: Notifications
    
    func apiGetScheduleSucceed(notification: NSNotification) {
        self.reloadData()
        self.reloadUI()
    }
    
    func apiGetScheduleFailed(notification: NSNotification) {
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: Helpers
    
    func titleForTms(tms: Int) -> String {
        let iDate = NSDate(timeIntervalSince1970: Double(tms))
        var title = ""
        
        let f = NSDateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        title = f.stringFromDate(NSDate(timeIntervalSince1970: Double(tms)))
        
        if iDate.isYesterday() {
            title = NSLocalizedString("Вчера")
        } else if iDate.isToday() {
            title = NSLocalizedString("Сегодня")
        } else if iDate.isTomorrow() {
            title = NSLocalizedString("Завтра")
        }
        
        return title
    }
    
    func dayTmsForTms(tms: Double) -> Int {
        var date = NSDate(timeIntervalSince1970: tms)
        let comps:NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
        date = NSCalendar.currentCalendar().dateFromComponents(comps)!
        return Int(date.timeIntervalSince1970)
    }
    
    func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        let unit:NSCalendarUnit = .Day
        let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
}
