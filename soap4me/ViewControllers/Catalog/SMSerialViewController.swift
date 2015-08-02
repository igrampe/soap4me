//
//  SMSerialViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 20/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

enum SMSerialViewControllerMode: Int {
    case None           = 0
    case Episodes       = 1
    case Description    = 2
    case Schedule       = 3
}

class SMSerialViewController: SMCollectionViewController, SMSerialHeaderDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let TableViewCellIdentifier = "TableViewCellIdentifier"
    let TableViewHeaderIdentifier = "TableViewHeaderIdentifier"
    
    var headerView: SMSerialHeader!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionView: UITextView!
    
    var sid: Int = 0
    var seasons = [NSObject]()
    var serial: SMSerial?
    var isWatching = false
    var metaEpisodes = [Int:[SMMetaEpisode]]()
    var mode: SMSerialViewControllerMode = .None
    var scheduleItems = [Int:[SMSerialScheduleItem]]()
    var scheduleItemsKeys = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView = SMSerialHeader()
        self.headerView.delegate = self;
        
        var backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 12, right: 31.5)
        backButton.frame = CGRectMake(0, 0, 44, 44)
        backButton.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88
        self.tableView.registerNib(UINib(nibName: "SMScheduleItemCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "SMScheduleHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: TableViewHeaderIdentifier)
        
        self.changeMode(.Episodes)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.frame = CGRectMake(0, -146, self.view.bounds.size.width, 146)
    }
    
    override func layoutOffset() {
        var offset: CGFloat = 0
        var shouldScroll = false
        if let navCtl = self.navigationController {
            offset = navCtl.navigationBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        self.headerView.frame = CGRectMake(0, -144, self.view.bounds.size.width, 146)
        self.refreshControlContainer.frame = CGRectMake(0, -self.headerView.frame.size.height, 0, 0)
        
        switch self.mode {
        case .Episodes:
            if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
                shouldScroll = true
            }
            self.collectionView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height+offset, 0, 0, 0)
            self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
            if shouldScroll {
                self.collectionView.setContentOffset(CGPointMake(0, -self.collectionView.contentInset.top), animated: false)
            }
        case .Description:
            self.descriptionView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height+offset, 0, 0, 0)
            self.descriptionView.scrollIndicatorInsets = self.descriptionView.contentInset
        case .Schedule:
            if (self.tableView.contentOffset.y == -self.tableView.contentInset.top) {
                shouldScroll = true
            }
            self.tableView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height+offset, 0, 0, 0)
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset
            if shouldScroll {
                self.tableView.setContentOffset(CGPointMake(0, -self.tableView.contentInset.top), animated: false)
            }
        default: break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
        self.reloadUI()
        self.obtainData()
        
        self.observe(selector: "apiGetEpisodesSucceed:", name: SMCatalogManagerNotification.ApiGetEpisodesSucceed.rawValue)
        self.observe(selector: "apiGetSerialMetaSucceed:", name: SMCatalogManagerNotification.ApiGetSerialMetaSucceed.rawValue)
        
        self.observe(selector: "apiSerialToggleWatchingSucceed:", name: SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue)
        self.observe(selector: "apiSerialToggleWatchingFailed:", name: SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue)
        
        self.observe(selector: "apiGetScheduleForSerialSucceed:", name: SMCatalogManagerNotification.ApiGetScheduleForSerialSucceed.rawValue)
        self.observe(selector: "apiGetScheduleForSerialFailed:", name: SMCatalogManagerNotification.ApiGetScheduleForSerialFailed.rawValue)
    }
    
    override func obtainData() {
        SMCatalogManager.sharedInstance.apiGetEpisodesForSid(self.sid)
        SMCatalogManager.sharedInstance.apiGetSerialMetaForSid(self.sid)
        SMCatalogManager.sharedInstance.apiGetScheduleForSid(self.sid)
    }

    override func reloadData() {
        var sortFunc = SMSeason.isOrderedBeforeAsc
        if SMStateManager.sharedInstance.catalogSorting == SMSorting.Descending {
            sortFunc = SMSeason.isOrderedBeforeDesc
        }
        
        self.seasons = SMCatalogManager.sharedInstance.getSeasonsForSid(sid).sorted(sortFunc)
        
        self.serial = SMCatalogManager.sharedInstance.getSerialWithSid(self.sid)
        self.isWatching = SMCatalogManager.sharedInstance.getIsWatchingSerialWithSid(self.sid)
        var mes = SMCatalogManager.sharedInstance.getMetaEpisodesForSid(self.sid)
        self.metaEpisodes.removeAll(keepCapacity: false)
        for me: SMMetaEpisode in mes {
            if self.metaEpisodes[me.season] == nil {
               self.metaEpisodes[me.season] = [SMMetaEpisode]()
            }
            self.metaEpisodes[me.season]?.append(me)
        }
        
        // Schedule
        self.scheduleItems.removeAll(keepCapacity: false)
        self.scheduleItemsKeys.removeAll(keepCapacity: false)
        var arr = SMCatalogManager.sharedInstance.getScheduleItemsForSid(self.sid)
        
        for object:SMSerialScheduleItem in arr {
            var objects:[SMSerialScheduleItem]? = self.scheduleItems[object.season_number]
            if objects == nil {
                objects = [SMSerialScheduleItem]()
                self.scheduleItems[object.season_number] = objects
            }
            self.scheduleItems[object.season_number]?.append(object)
        }
        self.scheduleItemsKeys.extend(self.scheduleItems.keys.array)
        self.scheduleItemsKeys.sort{(obj1: Int, obj2: Int) -> Bool in
            return obj1 > obj2
        }
        for key in self.scheduleItemsKeys {
            if var objects:[SMSerialScheduleItem] = self.scheduleItems[key] {
                objects.sort(SMSerialScheduleItem.isOrderedBefore)
            }
        }
    }
    
    override func reloadUI() {
        
        self.refreshControl.endRefreshing()
        self.title = self.serial?.title
        
        if let s = self.serial {
            self.headerView.titleLabel.text = s.title_ru
            var meta: String = "\(s.year)"
            var status = ""
            switch s.status {
            case 0: status = NSLocalizedString("Снимается")
            case 1: status = NSLocalizedString("Закончен")
            case 2: status = NSLocalizedString("Закрыт")
            default: break
            }
            meta = meta.stringByAppendingFormat(", %@", status)
            meta = meta.stringByAppendingFormat(", ☆%1.1f", s.imdb_rating)
            self.headerView.metaLabel.text = meta
            status = NSLocalizedString("Не смотрю")
            if self.isWatching {
                status = NSLocalizedString("Смотрю")
            }
            self.headerView.watchButton.setTitle(status, forState: UIControlState.Normal)
            let urlStr = String(format: SMApiHelper.ASSET_COVER_SERIAL_BIG, s.sid)
            
            var animated = true
            if let iu = imgsUrls[NSIndexPath(forRow: 0, inSection: -1)] {
                if iu == urlStr {
                    animated = false
                }
            }
            if animated {
                imgsUrls[NSIndexPath(forRow: 0, inSection: -1)] = urlStr
            }
            
            self.headerView.imageView.setImageUrl(urlStr, animated: animated)
        }
        
        self.collectionView.hidden = true
        self.descriptionView.hidden = true
        self.tableView.hidden = true
        
        self.headerView.removeFromSuperview()
        self.refreshControlContainer.removeFromSuperview()

        if self.mode == .Episodes {
            self.collectionView.hidden = false
            self.collectionView.reloadData()
            self.collectionView.addSubview(self.headerView)
            self.collectionView.addSubview(self.refreshControlContainer)
        } else if self.mode == .Description {
            self.descriptionView.text = self.serial?.desc
            self.descriptionView.hidden = false
            self.descriptionView.addSubview(self.headerView)
            self.descriptionView.addSubview(self.refreshControlContainer)
        } else if self.mode == .Schedule {
            self.tableView.hidden = false
            self.tableView.reloadData()
            self.tableView.addSubview(self.headerView)
            self.tableView.addSubview(self.refreshControlContainer)
        }
        self.layoutOffset()
    }
    
    //MARK: Actions
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func toggleWatching() {
        if self.isWatching {
            SMCatalogManager.sharedInstance.apiMarkSerialNotWatching(self.sid)
        } else {
            SMCatalogManager.sharedInstance.apiMarkSerialWatching(self.sid)
        }
    }
    
    func changeMode(aMode: SMSerialViewControllerMode) {
        if (self.mode == aMode) {
            return
        }
        self.mode = aMode
        self.reloadUI()
    }
    
    //MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.seasons.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: SMCatalogCollectionCell  = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! SMCatalogCollectionCell
        cell.titleLabel.text = "Title \(indexPath.row)"
        
        var object = self.seasons[indexPath.row]
        
        if let season = object as? SMSeason {
            var seasonTitle: String = String(format: "%@ %d", NSLocalizedString("Сезон"), season.season_number)
            var unwatched = 0
            if let mes: [SMMetaEpisode] = self.metaEpisodes[season.season_number] {
                seasonTitle = seasonTitle.stringByAppendingFormat("\n%d %@", mes.count, NSLocalizedString("Серий"))
                if self.isWatching {
                    for me: SMMetaEpisode in mes {
                        if !me.watched {
                            unwatched++
                        }
                    }
                    cell.setBadgeCount(unwatched)
                } else {
                    cell.setBadgeCount(0)
                }
            }
            cell.titleLabel.text = seasonTitle
            let urlStr = String(format: SMApiHelper.ASSET_COVER_SEASON_BIG, season.season_id)
            
            var animated = true
            if let iu = imgsUrls[indexPath] {
                if iu == urlStr {
                    animated = false
                }
            }
            if animated {
                imgsUrls[indexPath] = urlStr
            }
            
            cell.imageView.setImageUrl(urlStr, animated: animated)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var c: SMSeasonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SeasonVC") as! SMSeasonViewController
        var object: SMSeason!
        
        object = self.seasons[indexPath.row] as! SMSeason
        c.sid = self.sid
        c.season_id = object.season_id
        c.season_number = object.season_number
        
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var result = CGSizeZero
        if section == 0 {
//            result = CGSizeMake(self.view.bounds.size.width, 154)
        }
        return result
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }

    //MARK: Notifications
    
    func apiGetEpisodesSucceed(notification: NSNotification) {
        self.reloadData()
        self.reloadUI()
    }
    
    func apiSerialToggleWatchingSucceed(notification: NSNotification) {
        self.headerView.watchActivityIndicator.stopAnimating()
        self.headerView.watchButton.hidden = false
        self.reloadData()
        self.reloadUI()
    }
    
    func apiSerialToggleWatchingFailed(notification: NSNotification) {
        self.headerView.watchActivityIndicator.stopAnimating()
        self.headerView.watchButton.hidden = false
        self.reloadData()
        self.reloadUI()
    }
    
    func apiGetSerialMetaSucceed(notification: NSNotification) {
        self.reloadData()
        self.reloadUI()
    }
    
    func apiGetScheduleForSerialSucceed(notification: NSNotification) {
        self.reloadData()
        self.reloadUI()
    }
    
    func apiGetScheduleForSerialFailed(notification: NSNotification) {

    }
    
    //MARK: SMSerialHeaderDelegate
    
    func serialHeaderWatchAction(header: SMSerialHeader) {
        YMMYandexMetrica.reportEvent("APP.ACTION.SERIAL.HEADER.WATCH", onFailure: nil)
        self.headerView.watchActivityIndicator.startAnimating()
        self.headerView.watchButton.hidden = true
        self.toggleWatching()
    }
    
    func serialHeaderSeasonsAction(header: SMSerialHeader) {
        YMMYandexMetrica.reportEvent("APP.ACTION.SERIAL.HEADER.SEASONS", onFailure: nil)
        self.changeMode(.Episodes)
    }
    
    func serialHeaderDescriptionAction(header: SMSerialHeader) {
        YMMYandexMetrica.reportEvent("APP.ACTION.SERIAL.HEADER.DESCRIPTION", onFailure: nil)
        self.changeMode(.Description)
    }
    
    func serialHeaderScheduleAction(header: SMSerialHeader) {
        YMMYandexMetrica.reportEvent("APP.ACTION.SERIAL.HEADER.SCHEDULE", onFailure: nil)
        self.changeMode(.Schedule)
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.scheduleItemsKeys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        let key = self.scheduleItemsKeys[section]
        if let items = self.scheduleItems[key] {
            result = items.count
        }
        return result
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifier) as! SMScheduleItemCell
        
        let key = self.scheduleItemsKeys[indexPath.section]
        if let items = self.scheduleItems[key] {
            let item = items[indexPath.row]
            var df = NSDateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            var dateStr: String = df.stringFromDate(NSDate(timeIntervalSince1970: item.date))
            
            var str = String(format: "%@ - %@ %d\n", dateStr, NSLocalizedString("Cерия"), item.episode_number)
            let metaStr = str
            str = str.stringByAppendingString(item.title)
            var aStr = NSMutableAttributedString(string: str)
            var range = NSMakeRange(0, str.length())
            aStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
            aStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: range)
            range = NSMakeRange(metaStr.length(), item.title.length())
            aStr.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: "33bbff"), range: range)
            aStr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(17), range: range)
            cell.titleLabel.attributedText = aStr
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TableViewHeaderIdentifier) as? SMScheduleHeader
        
        let key:Int = self.scheduleItemsKeys[section]
        header?.titleLabel.text = String(format: "%@ %d", NSLocalizedString("Сезон"), key)
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
