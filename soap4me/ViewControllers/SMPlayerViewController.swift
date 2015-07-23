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

class SMPlayerViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player: AVPlayerViewController!
    
    var eid: Int = 0
    var sid: Int = 0
    var season_id: Int = 0
    var episode: Int = 0
    var hsh: String = ""
    var shouldRequestLink: Bool = true
    var startPosition: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player = AVPlayerViewController()
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        self.player.view.backgroundColor = UIColor.blackColor()
        
        self.observe(selector: "apiEpisodeGetLinkInfoSucceed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoSucceed.rawValue)
        self.observe(selector: "apiEpisodeGetLinkInfoFailed:", name: SMCatalogManagerNotification.ApiEpisodeGetLinkInfoFailed.rawValue)
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        
        self.player.view.hidden = true
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
            self.activityIndicator.stopAnimating()
            self.player.view.hidden = false
            self.player.player = AVPlayer(URL: NSURL(string: link))
            self.player.player.play()
            var targetTime: CMTime = CMTimeMakeWithSeconds(self.startPosition, self.player.player.currentTime().timescale)
            self.player.player.seekToTime(targetTime)
        }
    }
    
    func apiEpisodeGetLinkInfoFailed(notification: NSNotification) {
        
    }
    
    func goBack() {
        
    }
}
