//
//  SMScheduleViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 27/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMScheduleViewController: UITableViewController {

    private let CellIdentifier = "CellIdentifier"
    
    var scheduleItems = [Int: [SMScheduleItem]]()
    var scheduleKeys = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var v = UIView()
        v.backgroundColor = UIColor.blackColor()
        self.tableView.backgroundView = v
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.refreshControl?.addTarget(self, action: "obtainData", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.registerNib(UINib(nibName: "SMScheduleItemCell", bundle: nil), forCellReuseIdentifier: self.CellIdentifier)
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
            cell.titleLabel.text = item.title
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titleForTms(self.scheduleKeys[section])
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
