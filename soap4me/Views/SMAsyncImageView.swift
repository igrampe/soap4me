//
//  SMAsyncImageView.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import SDWebImage

protocol SMAsyncImageViewDelegate: NSObjectProtocol
{
    func imageViewDidLoadImage(imageView: SMAsyncImageView)
}

class SMAsyncImageView: UIImageView
{
    
    
    var activityIndicator: UIActivityIndicatorView?
    weak var delegate: SMAsyncImageViewDelegate?
    var indexPath: NSIndexPath?
    
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
        if let activityIndicator = self.activityIndicator
        {
            activityIndicator.hidesWhenStopped = true
            self.addSubview(activityIndicator)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let activityIndicator = self.activityIndicator
        {
            activityIndicator.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        }
    }
    
    func setImageUrl(urlStr: String) {
        self.setImageUrl(urlStr, animated: true)
    }
    
    func setImageUrl(urlStr: String, animated: Bool) {
        if let activityIndicator = self.activityIndicator
        {
            activityIndicator.startAnimating()
        }
        if let url = NSURL(string: urlStr) {
            self.sd_setImageWithURL(url, completed: { (image, error, _, _) -> Void in
                if let activityIndicator = self.activityIndicator
                {
                    activityIndicator.stopAnimating()
                }
                self.delegate?.imageViewDidLoadImage(self)
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
