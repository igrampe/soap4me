//
//  SMPlayerViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import MediaPlayer

class SMPlayerViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player: MPMoviePlayerController!
    
    var eid: Int = 0
    var sid: Int = 0
    var season_id: Int = 0
    var episode: Int = 0
    var hsh: String = ""
    var shouldRequestLink: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = MPMoviePlayerController()
        self.player.view.backgroundColor = UIColor.blackColor()
        
        self.observe(selector: "playbackStateChanged:", name: MPMoviePlayerPlaybackStateDidChangeNotification)
        self.observe(selector: "playerDidFinish", name: MPMoviePlayerPlaybackDidFinishNotification)
        self.observe(selector: "playerDidExiFullScreen", name: MPMoviePlayerDidExitFullscreenNotification)
        self.observe(selector: "apiEpisodeGetLinkInfoSucceed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoSucceed.rawValue)
        self.observe(selector: "apiEpisodeGetLinkInfoFailed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoFailed.rawValue)
        
        self.view.addSubview(self.player.view)
        self.player.view.hidden = true
        self.player.movieSourceType = MPMovieSourceType.File
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.player.view.frame = self.view.bounds;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.shouldRequestLink) {
            self.activityIndicator.startAnimating()
            SMCatalogManager.sharedInstance.apiGetLinkInfoForEid(self.eid, sid: self.sid, hash: self.hsh)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    //MARK: Notifications
    
    func apiEpisodeGetLinkInfoSucceed(notification: NSNotification) {
        if let link = notification.object as? String {
            self.player.view.hidden = false
            self.player.contentURL = NSURL(string: link)
            self.player.prepareToPlay()
            self.player.setFullscreen(true, animated: false)
            self.player.controlStyle = MPMovieControlStyle.Fullscreen
            self.player.play()
        }
    }
    
    func playbackStateChanged(notification: NSNotification) {
        if self.player.playbackState == MPMoviePlaybackState.Playing {
            if self.activityIndicator.isAnimating() {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func apiEpisodeGetLinkInfoFailed(notification: NSNotification) {
        
    }
    
    func playerDidFinish() {
        self.finishPlayer()
    }
    
    func playerDidExiFullScreen() {
        self.finishPlayer()
    }
    
    func finishPlayer() {
        SMCatalogManager.sharedInstance.setPlayingProgress(self.player.playableDuration/self.player.duration, forSeasonId: self.season_id, episodeNumber: self.episode)
        self.shouldRequestLink = false
        self.player.stop()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
