//
//  SMSeasonViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import SVProgressHUD

struct SelectedEpisode {
    var eid: Int = 0
    var hsh: String = ""
    var sid: Int = 0
    var episode_number: Int = 0
    var season_id: Int = 0
    var progress: Double = 0
}

class SMSeasonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SMEpisodeCellDelegate, UIAlertViewDelegate, SMPlayerViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sid: Int = 0
    var season_id: Int = 0
    var season_number: Int = 0
    var tryToWatchEpisodes = [Int:Bool]()
    var metaEpisodes = [SMMetaEpisode]()
    let cellIdentifier = "cellIdentifier"
    
    var selectedEpisode: SelectedEpisode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 12, right: 31.5)
        backButton.frame = CGRectMake(0, 0, 44, 44)
        backButton.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let markButton = UIButton()
        markButton.setImage(UIImage(named: "mark_all"), forState: UIControlState.Normal)
        markButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 25, bottom: 12, right: 0)
        markButton.frame = CGRectMake(0, 0, 44, 44)
        markButton.addTarget(self, action: "markAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: markButton)
        
        self.reloadData()
        self.reloadUI()        
        self.tableView.registerNib(UINib(nibName: "SMEpisodeCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
        self.observe(selector: "apiEpisodeToggleWatchedSucceed:", name: SMCatalogManagerNotification.ApiEpisodeToggleWatchedSucceed.rawValue)
        
        self.observe(selector: "apiSeasonMarkWatchedSucceed:", name: SMCatalogManagerNotification.ApiSeasonMarkWatchedSucceed.rawValue)
        self.observe(selector: "apiSeasonMarkWatchedFailed:", name: SMCatalogManagerNotification.ApiSeasonMarkWatchedFailed.rawValue)
    }
    
    func reloadData() {
        var sortFunc = SMMetaEpisode.isOrderedBeforeAsc
        if SMStateManager.sharedInstance.catalogSorting == SMSorting.Descending {
            sortFunc = SMMetaEpisode.isOrderedBeforeDesc
        }
        self.metaEpisodes = SMCatalogManager.sharedInstance.getMetaEpisodesForSeasonId(self.season_id).sort(sortFunc)
    }
    
    func reloadUI() {
        self.tableView.reloadData()
        self.title = String(format: "%@ %d", NSLocalizedString("Сезон"), self.season_number)
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func markAction() {
        let alertView = UIAlertView(title: NSLocalizedString("Внимание!"), message: NSLocalizedString("Отметить сезон как просмотренный?"), delegate: self, cancelButtonTitle: NSLocalizedString("Нет"), otherButtonTitles:NSLocalizedString("Да"))
        alertView.tag = 2
        alertView.show()
    }
    
    func showPlayer() {
        if let se = self.selectedEpisode {
            let c: SMPlayerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PlayerVC") as! SMPlayerViewController
            c.eid = se.eid
            c.hsh = se.hsh
            c.sid = se.sid
            c.episode = se.episode_number
            c.season_id = se.season_id
            c.startPosition = se.progress
            c.vcdelegate = self
            self.navigationController?.presentViewController(c, animated: true, completion: nil)
        }
    }

    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.metaEpisodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SMEpisodeCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! SMEpisodeCell
        
        let metaEpisode = self.metaEpisodes[indexPath.row]
        
        cell.numberLabel.text = String(format: "%d", metaEpisode.episode)
        cell.titleLabel.text = metaEpisode.title_ru
        
        cell.setWatched(metaEpisode.watched)
        cell.delegate = self
        cell.indexPath = indexPath
        
        if let _ = self.tryToWatchEpisodes[metaEpisode.episode] {
            cell.activityIndicator.startAnimating()
            cell.watchButton.hidden = true
        } else {
            cell.activityIndicator.stopAnimating()
            cell.watchButton.hidden = false
        }
        
        if SMStateManager.sharedInstance.preferedTranslation == SMEpisodeTranslateType.Voice &&
            !metaEpisode.hasVoice {
            cell.subLabel.hidden = false
        } else {
            cell.subLabel.hidden = true
        }
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if !SMStateManager.sharedInstance.canPlaySerials() {
            return
        }
        
        let metaEpisode = self.metaEpisodes[indexPath.row]
        
        if let episode = metaEpisode.episodeWithQuality(SMStateManager.sharedInstance.preferedQuality,
            translationType: SMStateManager.sharedInstance.preferedTranslation) {
                var shouldAscContinue = false
                var progress: Double = 0
                if let ep: SMEpisodeProgress = SMCatalogManager.sharedInstance.getEpisodeProgress(forSeasonId: episode.season_id, episodeNumber: episode.episode) {
                    if ep.progress > 10 {
                        shouldAscContinue = true
                        progress = ep.progress
                    }
                }
                
                self.selectedEpisode = SelectedEpisode(eid: episode.eid, hsh: episode.hsh, sid: episode.sid, episode_number: episode.episode, season_id: episode.season_id, progress: progress)
                
                if shouldAscContinue {
                    let alertView = UIAlertView()
                    alertView.delegate = self
                    alertView.title = NSLocalizedString("Продолжить воспроизведение?")
                    alertView.addButtonWithTitle(NSLocalizedString("Нет"))
                    alertView.addButtonWithTitle(NSLocalizedString("Да"))
                    alertView.cancelButtonIndex = 0
                    alertView.tag = 1
                    alertView.show()
                } else {
                    self.showPlayer()
                }
                
        }
    }
    
    //MARK: SMEpisodeCellDelegate
    
    func episodeCellWatchAction(cell: SMEpisodeCell) {
        let metaEpisode = self.metaEpisodes[cell.indexPath.row]
        if let episode = metaEpisode.episodes.firstObject() as? SMEpisode {
            self.tryToWatchEpisodes[metaEpisode.episode] = true
            SMCatalogManager.sharedInstance.apiMarkEpisodeWatched(episode.eid, watched: !metaEpisode.watched)
            self.tableView.reloadData()
//            self.tableView.reloadRowsAtIndexPaths([cell.indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
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
    
    func apiSeasonMarkWatchedSucceed(notification: NSNotification) {
        SVProgressHUD.dismiss()
        self.reloadData()
        self.reloadUI()
    }
    
    func apiSeasonMarkWatchedFailed(notification: NSNotification) {
        var msg = ""
        if let error = notification.object as? NSError {
            msg = error.localizedDescription
        }
        SVProgressHUD.showErrorWithStatus(msg)
    }
    
    //MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            if buttonIndex == 1 {
                self.showPlayer()
            } else {
                self.selectedEpisode?.progress = 0
                self.showPlayer()
            }
        } else if alertView.tag == 2 {
            if buttonIndex == 1 {
                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
                SMCatalogManager.sharedInstance.apiMarkSeasonWatchedForSid(self.sid, season: self.season_number)
            }
        }
    }
    
    //MARK: SMPlayerViewControllerDelegate
    
    func playerCtlMarkCurrentEpsisodeWatched(ctl: SMPlayerViewController) {
        self.tryToWatchEpisodes[ctl.episode] = true
        SMCatalogManager.sharedInstance.apiMarkEpisodeWatched(ctl.eid, watched: true)
        var index: Int = -1
        for var i = 0; i < self.metaEpisodes.count; i++ {
            let metaEpisode: SMMetaEpisode = self.metaEpisodes[i]
            if metaEpisode.season_id == ctl.season_id && metaEpisode.episode == ctl.episode {
                index = i
            }
        }
        if index >= 0 {
            self.tableView.reloadData()
//            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func getNextEpisodeForPlayer(ctl: SMPlayerViewController) {
        var index: Int = -1
        for var i = 0; i < self.metaEpisodes.count; i++ {
            let metaEpisode: SMMetaEpisode = self.metaEpisodes[i]
            if metaEpisode.season_id == ctl.season_id && metaEpisode.episode == ctl.episode {
                index = i
            }
        }
        if index >= 0 {
            if SMStateManager.sharedInstance.catalogSorting == SMSorting.Ascending {
                index++
            } else if SMStateManager.sharedInstance.catalogSorting == SMSorting.Descending {
                index--
            }
            if index < self.metaEpisodes.count && index >= 0 {
                let metaEpisode: SMMetaEpisode = self.metaEpisodes[index]
                if let episode = metaEpisode.episodeWithQuality(SMStateManager.sharedInstance.preferedQuality,
                    translationType: SMStateManager.sharedInstance.preferedTranslation) {
                    ctl.eid = episode.eid
                    ctl.hsh = episode.hsh
                    ctl.sid = episode.sid
                    ctl.episode = episode.episode
                    ctl.season_id = episode.season_id
                    ctl.nextPlay()
                }
            } else {
                ctl.stopPlaying()
            }
        } else {
            ctl.stopPlaying()
        }
    }
}
