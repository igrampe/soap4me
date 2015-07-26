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
    
    var headerView: SMSerialHeader!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionView: UITextView!
    
    var sid: Int = 0
    var seasons = [NSObject]()
    var serial: SMSerial?
    var isWatching = false
    var metaEpisodes = [Int:[SMMetaEpisode]]()
    var mode: SMSerialViewControllerMode = .None
    
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
        
        SMCatalogManager.sharedInstance.apiGetEpisodesForSid(self.sid)
        
        self.changeMode(.Episodes)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.frame = CGRectMake(0, -146, self.view.bounds.size.width, 146)
    }
    
    override func layoutOffset() {
        var offset: CGFloat = 0
        var shouldScroll = false
        if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
            shouldScroll = true
        }
        if let navCtl = self.navigationController {
            offset = navCtl.navigationBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        self.headerView.frame = CGRectMake(0, -144, self.view.bounds.size.width, 146)
        self.refreshControlContainer.frame = CGRectMake(0, -self.headerView.frame.size.height, 0, 0)
        self.collectionView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height+offset, 0, 0, 0)
        self.descriptionView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height+offset, 0, 0, 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(offset, 0, 0, 0)
        if shouldScroll {
            self.collectionView.setContentOffset(CGPointMake(0, -self.collectionView.contentInset.top), animated: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
        self.reloadUI()
        self.obtainData()
        self.observe(selector: "apiGetEpisodesSucceed:", name: SMCatalogManagerNotification.ApiGetEpisodesSucceed.rawValue)
        self.observe(selector: "apiSerialToggleWatchingSucceed:", name: SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue)
        self.observe(selector: "apiSerialToggleWatchingFailed:", name: SMCatalogManagerNotification.ApiSerialToggleWatchingFailed.rawValue)
    }
    
    override func obtainData() {
        SMCatalogManager.sharedInstance.apiGetEpisodesForSid(self.sid)
    }

    override func reloadData() {
        self.seasons = SMCatalogManager.sharedInstance.getSeasonsForSid(sid).sorted(SMSeason.isOrderedBefore)
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
            if let iu = imgsUrls[-1] {
                if iu == urlStr {
                    animated = false
                }
            }
            if animated {
                imgsUrls[-1] = urlStr
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
            if let iu = imgsUrls[indexPath.row] {
                if iu == urlStr {
                    animated = false
                }
            }
            if animated {
                imgsUrls[indexPath.row] = urlStr
            }
            
            cell.imageView.setImageUrl(urlStr, animated: animated)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var c: SMSeasonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SeasonVC") as! SMSeasonViewController
        var object: SMSeason!
        
        object = self.seasons[indexPath.row] as! SMSeason
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
    
    //MARK: SMSerialHeaderDelegate
    
    func serialHeaderWatchAction(header: SMSerialHeader) {
        self.headerView.watchActivityIndicator.startAnimating()
        self.headerView.watchButton.hidden = true
        self.toggleWatching()
    }
    
    func serialHeaderSeasonsAction(header: SMSerialHeader) {
        self.changeMode(.Episodes)
    }
    
    func serialHeaderDescriptionAction(header: SMSerialHeader) {
        self.changeMode(.Description)
    }
    
    func serialHeaderScheduleAction(header: SMSerialHeader) {
//        self.changeMode(.Schedule)
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("") as! UITableViewCell
        return cell
    }
}
