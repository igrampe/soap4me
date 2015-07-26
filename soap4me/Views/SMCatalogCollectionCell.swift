//
//  SMCatalogCollectionCell.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

class SMCatalogCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: SMAsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: SMPaddingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.badgeLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        self.badgeLabel.layer.cornerRadius = 11
        self.badgeLabel.layer.masksToBounds = true
    }
    
    func setBadgeCount(count: Int) {
        if count > 0 {
            self.badgeLabel.text = "\(count)"
            self.badgeLabel.hidden = false
        } else {
            self.badgeLabel.hidden = true
        }
    }
}
