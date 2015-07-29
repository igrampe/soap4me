//
//  SMEpisodeCell.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

protocol SMEpisodeCellDelegate: NSObjectProtocol {
    func episodeCellWatchAction(cell: SMEpisodeCell)
}

class SMEpisodeCell: UITableViewCell {

    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: SMPaddingLabel!
    
    weak var delegate: SMEpisodeCellDelegate?
    var indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.watchButton.layer.cornerRadius = 15
        self.watchButton.layer.masksToBounds = true
        self.watchButton.layer.borderColor = UIColor.colorWithString("33bbff").CGColor
        self.watchButton.backgroundColor = UIColor.colorWithString("33bbff")
        
        self.subLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        self.subLabel.layer.cornerRadius = 5
        self.subLabel.layer.borderWidth = 1
        self.subLabel.layer.borderColor = UIColor.whiteColor().CGColor
        self.subLabel.layer.masksToBounds = true
    }
    
    func setWatched(watched: Bool) {
        if watched {
            self.watchButton.backgroundColor = UIColor.clearColor()
            self.watchButton.layer.borderWidth = 1
        } else {
            self.watchButton.layer.borderWidth = 0
            self.watchButton.backgroundColor = UIColor.colorWithString("33bbff")
        }
    }

    @IBAction func watchAction() {
        self.delegate?.episodeCellWatchAction(self)
    }
}
