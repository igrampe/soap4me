//
//  SMSeasonsViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 20/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMSeasonsViewController: SMCollectionViewController, SMSerialHeaderDelegate {
    
    var sid: Int = 0
    var seasons = [NSObject]()
    var serial: SMSerial?
    var isWatching = false
    var metaEpisodes = [Int:[SMMetaEpisode]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 12, right: 31.5)
        backButton.frame = CGRectMake(0, 0, 44, 44)
        backButton.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.collectionView.registerNib(UINib(nibName: "SMSerialReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
        
        SMCatalogManager.sharedInstance.apiGetEpisodesForSid(self.sid)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
        self.reloadUI()
        self.obtainData()
        self.observe(selector: "apiGetEpisodesSucceed:", name: SMCatalogManagerNotification.ApiGetEpisodesSucceed.rawValue)
        self.observe(selector: "apiSerialToggleWatchingSucceed:", name: SMCatalogManagerNotification.ApiSerialToggleWatchingSucceed.rawValue)
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
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
        self.title = self.serial?.title
        self.collectionView.reloadData()
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
            if let url = NSURL(string: urlStr) {
                cell.imageView.sd_setImageWithURL(url)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: SMSerialReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier, forIndexPath: indexPath) as! SMSerialReusableView
        
        view.delegate = self
        
        if let s = self.serial {
            view.titleLabel.text = s.title_ru
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
            view.metaLabel.text = meta
            status = NSLocalizedString("Не смотрю")
            if self.isWatching {
                status = NSLocalizedString("Смотрю")
            }
            view.watchButton.setTitle(status, forState: UIControlState.Normal)
            let urlStr = String(format: SMApiHelper.ASSET_COVER_SERIAL_BIG, s.sid)
            if let url = NSURL(string: urlStr) {
                view.imageView.sd_setImageWithURL(url)
            }
        }
        
        return view
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var result = CGSizeZero
        if section == 0 {
            result = CGSizeMake(self.view.bounds.size.width, 116)
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
        self.reloadData()
        self.reloadUI()
    }
    
    //MARK: SMSerialHeaderDelegate
    
    func serialHeaderWatchAction(header: SMSerialReusableView) {
        self.toggleWatching()
    }
    
    func serialHeaderDescriptionAction(header: SMSerialReusableView) {
        
    }
    
    func serialHeaderScheduleAction(header: SMSerialReusableView) {
        
    }
}
