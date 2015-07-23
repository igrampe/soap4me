//
//  SMSeasonViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMSeasonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SMEpisodeCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var season_id: Int = 0
    var season_number: Int = 0
    var tryToWatchEpisodes = [Int:Bool]()
    var metaEpisodes = [SMMetaEpisode]()
    let cellIdentifier = "cellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 12, right: 31.5)
        backButton.frame = CGRectMake(0, 0, 44, 44)
        backButton.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        self.reloadData()
        self.reloadUI()        
        self.tableView.registerNib(UINib(nibName: "SMEpisodeCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        self.observe(selector: "apiEpisodeToggleWatchedSucceed:", name: SMCatalogManagerNotification.ApiEpisodeToggleWatchedSucceed.rawValue)
    }
    
    func reloadData() {
        self.metaEpisodes = SMCatalogManager.sharedInstance.getMetaEpisodesForSeasonId(self.season_id).sorted(SMMetaEpisode.isOrderedBefore)
    }
    
    func reloadUI() {
        self.tableView.reloadData()
        self.title = String(format: "%@ %d", NSLocalizedString("Сезон"), self.season_number)
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.metaEpisodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SMEpisodeCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! SMEpisodeCell
        
        let metaEpisode = self.metaEpisodes[indexPath.row]
        
        cell.numberLabel.text = String(format: "%d", indexPath.row+1)
        cell.titleLabel.text = metaEpisode.title_ru
        
        cell.setWatched(metaEpisode.watched)
        cell.delegate = self
        cell.indexPath = indexPath
        
        if let ttwe = self.tryToWatchEpisodes[metaEpisode.episode] {
            cell.activityIndicator.startAnimating()
            cell.watchButton.hidden = true
        } else {
            cell.activityIndicator.stopAnimating()
            cell.watchButton.hidden = false
        }
        
        return cell
    }
    
    //MARK: SMEpisodeCellDelegate
    
    func episodeCellWatchAction(cell: SMEpisodeCell) {
        var metaEpisode = self.metaEpisodes[cell.indexPath.row]
        if let episode = metaEpisode.episodes.firstObject() as? SMEpisode {
            self.tryToWatchEpisodes[metaEpisode.episode] = true
            SMCatalogManager.sharedInstance.apiMarkEpisodeWatched(episode.eid, watched: !metaEpisode.watched)
            self.tableView.reloadRowsAtIndexPaths([cell.indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    //MARK: Notifications
    
    func apiEpisodeToggleWatchedSucceed(notification: NSNotification) {
        if let episode = notification.object as? Int {
            self.tryToWatchEpisodes.removeValueForKey(episode)
        }
        self.reloadData()
        self.reloadUI()
    }
}
