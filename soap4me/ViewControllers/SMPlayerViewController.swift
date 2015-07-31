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

class SMPlayerViewController: AVPlayerViewController {
    
    var eid: Int = 0
    var sid: Int = 0
    var season_id: Int = 0
    var episode: Int = 0
    var hsh: String = ""
    var shouldRequestLink: Bool = true
    var startPosition: Double = 0
    var timer: NSTimer?
    
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
    }
    
    //MARK: Notifications
    
    func apiEpisodeGetLinkInfoSucceed(notification: NSNotification) {
        if let link = notification.object as? String {
            var item = AVPlayerItem(URL: NSURL(string: link))
            self.player = AVPlayer(playerItem: item)
//            self.player = AVPlayer(URL: NSURL(string: link))
            self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &сontext)
            self.observe(selector: "didPlayToEnd:", name: AVPlayerItemDidPlayToEndTimeNotification)
            self.player.status
            self.shouldRequestLink = false
        }
    }
    
    func apiEpisodeGetLinkInfoFailed(notification: NSNotification) {
        
    }
    
    func didPlayToEnd(notification: NSNotification) {
        SMCatalogManager.sharedInstance.setPlayingProgress(0, forSeasonId: self.season_id,
            episodeNumber: self.episode)
        self.player.pause()
        self.dismissViewControllerAnimated(true, completion: nil)
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
    }
    
    func timerTick() {
        let progress = Double(self.player.currentTime().value)/Double(self.player.currentTime().timescale)
        SMCatalogManager.sharedInstance.setPlayingProgress(progress, forSeasonId: self.season_id, episodeNumber: self.episode)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &сontext {
            if self.player.status == AVPlayerStatus.ReadyToPlay {
                var targetTime: CMTime = CMTimeMakeWithSeconds(self.startPosition, self.player.currentTime().timescale)
                self.player.seekToTime(targetTime, completionHandler: { (_) -> Void in
                    self.player.play()
                })
                if let t = self.timer {
                    t.invalidate()
                }
                self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timerTick", userInfo: nil, repeats: true)
                
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "status", context: &сontext)
        self.stopObserve()
    }
    
    
}
