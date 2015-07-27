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

class SMScheduleViewController: UITableViewController {

    private let CellIdentifier = "CellIdentifier"
    private let HeaderIdentifier = "HeaderIdentifier"
    
    var scheduleItems = [Int: [SMScheduleItem]]()
    var scheduleKeys = [Int]()
    var scheduleMode: SMScheduleMode = .My
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
//        var v = UIView()
//        v.backgroundColor = UIColor.clearColor()
//        self.tableView.backgroundView = v
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.blackColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "obtainData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.endRefreshing()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88
        
        self.tableView.registerNib(UINib(nibName: "SMScheduleItemCell", bundle: nil), forCellReuseIdentifier: self.CellIdentifier)
        self.tableView.registerNib(UINib(nibName: "SMScheduleHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderIdentifier)
        self.obtainData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.observe(selector: "apiGetScheduleSucceed:", name: SMCatalogManagerNotification.ApiGetScheduleSucceed.rawValue)
        self.observe(selector: "apiGetScheduleFailed:", name: SMCatalogManagerNotification.ApiGetScheduleFailed.rawValue)
        self.reloadData()
        self.reloadUI()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setMode(mode: SMScheduleMode) {
        self.scheduleMode = mode
        self.reloadData()
        self.reloadUI()
    }
    
    func obtainData() {
        SMCatalogManager.sharedInstance.apiGetScheduleMy()
    }
    
    func reloadData() {
        self.scheduleItems.removeAll(keepCapacity: false)
        self.scheduleKeys.removeAll(keepCapacity: false)
        var itms = SMCatalogManager.sharedInstance.getScheduleItemsMy()
        for it in itms {
            var tms = self.dayTmsForTms(it.date)
            var arr = self.scheduleItems[tms]
            if arr == nil {
                self.scheduleItems[tms] = [SMScheduleItem]()
            }
            self.scheduleItems[tms]?.append(it)
        }
        
        self.scheduleKeys.extend(scheduleItems.keys.array)
        self.scheduleKeys.sort { (obj1: Int, obj2: Int) -> Bool in
            return obj1 < obj2
        }
    }
    
    func reloadUI() {
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var result = 0
        result = self.scheduleKeys.count
        return result
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if let items = self.scheduleItems[self.scheduleKeys[section]] {
            result = items.count
        }
        return result
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! SMScheduleItemCell
        
        
        if let items = self.scheduleItems[self.scheduleKeys[indexPath.section]] {
            var item: SMScheduleItem = items[indexPath.row]
            var str = String(format: "%@. %@ %d, %@ %d.\n%@", item.serial_name, NSLocalizedString("Сезон"), item.season_number, NSLocalizedString("cерия"), item.episode_number, item.title)
            var aStr = NSMutableAttributedString(string: str)
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

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderIdentifier) as? SMScheduleHeader
        
        header?.titleLabel.text = self.titleForTms(self.scheduleKeys[section])
        
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //MARK: Notifications
    
    func apiGetScheduleSucceed(notification: NSNotification) {
        self.reloadData()
        self.reloadUI()
        self.refreshControl?.endRefreshing()
    }
    
    func apiGetScheduleFailed(notification: NSNotification) {
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: Helpers
    
    func titleForTms(tms: Int) -> String {
        let nowDate = NSDate()
        let iDate = NSDate(timeIntervalSince1970: Double(tms))
        var title = ""
        let ti = nowDate.timeIntervalSinceDate(iDate)
        
        var f = NSDateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        title = f.stringFromDate(NSDate(timeIntervalSince1970: Double(tms)))
        
        if ti > 0 {
            if ti < 24*60*60 {
                title = NSLocalizedString("Сегодня")
            } else if ti < 2*24*60*60 {
                title = NSLocalizedString("Завтра")
            }
        } else {
            if fabs(ti) < 24*60*60 {
                title = NSLocalizedString("Сегодня")
            } else if fabs(ti) < 2*24*60*60 {
                title = NSLocalizedString("Вчера")
            }
        }
        
        return title
    }
    
    func dayTmsForTms(tms: Double) -> Int {
        var result: Int = 0
        var date = NSDate(timeIntervalSince1970: tms)
        var comps:NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay, fromDate: date)
        date = NSCalendar.currentCalendar().dateFromComponents(comps)!
        return Int(date.timeIntervalSince1970)
    }
}
