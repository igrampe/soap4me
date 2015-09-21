//
//  SMAsyncImageView.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import SDWebImage

class SMAsyncImageView: UIImageView {

    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.activityIndicator.hidesWhenStopped = true
        self.addSubview(self.activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setImageUrl(urlStr: String) {
        self.setImageUrl(urlStr, animated: true)
    }
    
    func setImageUrl(urlStr: String, animated: Bool) {
        self.activityIndicator.startAnimating()
        if let url = NSURL(string: urlStr) {
            self.sd_setImageWithURL(url, completed: { (image, error, _, _) -> Void in
                self.activityIndicator.stopAnimating()
                if animated {
                    self.layer.opacity = 0
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.layer.opacity = 1
                    })
                }
            })
        }
    }
}
