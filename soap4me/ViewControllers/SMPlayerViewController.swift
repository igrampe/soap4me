//
//  SMPlayerViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

protocol SMPlayerViewControllerDelegate: NSObjectProtocol {
    func playerCtlMarkCurrentEpsisodeWatched(ctl: SMPlayerViewController)
    func getNextEpisodeForPlayer(ctl: SMPlayerViewController)
}

class SMPlayerViewController: AVPlayerViewController {
    
    var eid: Int = 0
    var sid: Int = 0
    var season_id: Int = 0
    var episode: Int = 0
    var hsh: String = ""
    var shouldRequestLink: Bool = true
    var startPosition: Double = 0
    var timer: NSTimer?
    weak var vcdelegate: SMPlayerViewControllerDelegate?
    
    private var сontext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        self.observe(selector: "apiEpisodeGetLinkInfoSucceed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoSucceed.rawValue)
        self.observe(selector: "apiEpisodeGetLinkInfoFailed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoFailed.rawValue)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        if (self.shouldRequestLink) {
            SMCatalogManager.sharedInstance.apiGetLinkInfoForEid(self.eid, sid: self.sid, hash: self.hsh)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        if let _ = self.player
        {
            self.player!.removeObserver(self, forKeyPath: "status", context: &сontext)
        }
    }
    
    func stopPlaying() {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
    }
    
    func nextPlay() {
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
        if let _ = self.player
        {
            self.player!.removeObserver(self, forKeyPath: "status", context: &сontext)
        }
        self.shouldRequestLink = true
        SMCatalogManager.sharedInstance.apiGetLinkInfoForEid(self.eid, sid: self.sid, hash: self.hsh)
    }
    
    //MARK: Notifications
    
    func apiEpisodeGetLinkInfoSucceed(notification: NSNotification) {
        if let link = notification.object as? String {
            let item = AVPlayerItem(URL: NSURL(string: link)!)
            self.player = AVPlayer(playerItem: item)
//            self.player = AVPlayer(URL: NSURL(string: link))
            if let _ = self.player
            {
                self.player!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &сontext)
            }
            self.observe(selector: "didPlayToEnd:", name: AVPlayerItemDidPlayToEndTimeNotification)
            self.shouldRequestLink = false
            
            SMStateManager.sharedInstance.lastPlayingEid = self.eid
        }
    }
    
    func apiEpisodeGetLinkInfoFailed(notification: NSNotification) {
        let alertView = UIAlertView(title: NSLocalizedString("Ошибка"), message: NSLocalizedString("Не удалось получить ссылку на видео, попробуйте снова"), delegate: self, cancelButtonTitle: NSLocalizedString("ОК"))
        alertView.show()
    }
    
    func didPlayToEnd(notification: NSNotification) {
        SMStateManager.sharedInstance.lastPlayingEid = 0
        SMCatalogManager.sharedInstance.setPlayingProgress(0, forSeasonId: self.season_id,
            episodeNumber: self.episode)
        if let _ = self.player
        {
            self.player!.pause()
        }
        if self.vcdelegate != nil && SMStateManager.sharedInstance.shouldContinueWithNextEpisode {
            self.vcdelegate!.getNextEpisodeForPlayer(self)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
            if let t = self.timer {
                t.invalidate()
                self.timer = nil
            }
        }
    }
    
    func timerTick() {
        if let _ = self.player
        {
            let progress = Double(self.player!.currentTime().value)/Double(self.player!.currentTime().timescale)
            SMCatalogManager.sharedInstance.setPlayingProgress(progress, forSeasonId: self.season_id, episodeNumber: self.episode)
            
            if let currentItem = self.player!.currentItem
            {
                let duration = Double(currentItem.duration.value)/Double(currentItem.duration.timescale)
                if duration.isNormal {
                    if progress/duration >= 0.95 {
                        self.vcdelegate?.playerCtlMarkCurrentEpsisodeWatched(self)
                    }
                }
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &сontext {
            if let _ = self.player
            {
                if self.player!.status == AVPlayerStatus.ReadyToPlay {
                    let targetTime: CMTime = CMTimeMakeWithSeconds(self.startPosition, self.player!.currentTime().timescale)
                    self.player!.seekToTime(targetTime, completionHandler: { (_) -> Void in
                        self.player!.play()
                    })
                    if let t = self.timer {
                        t.invalidate()
                    }
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerTick", userInfo: nil, repeats: true)
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        self.stopObserve()
    }
}
