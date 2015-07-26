//
//  SMSerialsViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 19/07/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit
import SDWebImage

protocol SMSerialsViewControllerDataSource: NSObjectProtocol {
    func numberOfSectionsForSerialsCtl(ctl: SMSerialsViewController) -> Int
    func serialsCtl(ctl: SMSerialsViewController, numberOfObjectsInSection section: Int) -> Int
    func serialsCtl(ctl: SMSerialsViewController, objectAtIndexPath indexPath: NSIndexPath) -> NSObject
    func serialsCtl(ctl: SMSerialsViewController, titleForSection section: Int) -> String?
}

protocol SMSerialsViewControllerDelegate: NSObjectProtocol {
    func serialsCtl(ctl: SMSerialsViewController, didSelectItemAtIndexPath indexPath: NSIndexPath)
    func serialsCtlNeedObtainData(ctl: SMSerialsViewController)
}

class SMSerialsViewController: SMCollectionViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var dataSource: SMSerialsViewControllerDataSource?
    weak var delegate: SMSerialsViewControllerDelegate?
    
    var mySerials: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.registerNib(UINib(nibName: "SMCatalogReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
        self.obtainData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadUI()
    }
    
    override func layoutOffset() {
        var shouldScroll = false
        if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
            shouldScroll = true
        }
        super.layoutOffset()
        if shouldScroll {
            self.collectionView.setContentOffset(CGPointMake(0, -self.collectionView.contentInset.top), animated: false)
        }
    }
    
    override func obtainData() {
        self.delegate?.serialsCtlNeedObtainData(self)
    }

    override func reloadUI() {
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
        self.layoutOffset()
    }
    
    //MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var result = 0
        if let n = self.dataSource?.numberOfSectionsForSerialsCtl(self) {
            result = n
        }
        return result
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        if let n = self.dataSource?.serialsCtl(self, numberOfObjectsInSection: section) {
            result = n
        }
        return result
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: SMCatalogCollectionCell  = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! SMCatalogCollectionCell
        cell.titleLabel.text = "Title \(indexPath.row)"
        
        var object = self.dataSource?.serialsCtl(self, objectAtIndexPath: indexPath)
        
        if let serial = object as? SMSerial {
            cell.titleLabel.text = serial.title
            let urlStr = String(format: SMApiHelper.ASSET_COVER_SERIAL_BIG, serial.sid)
            
            var animated = true
            if let iu = imgsUrls[indexPath.row] {
                if iu == urlStr {
                    animated = false
                }
            }
            if animated {
                imgsUrls[indexPath.row] = urlStr
            }
            
            cell.imageView.setImageUrl(urlStr, animated: animated)
            
            if (self.mySerials) {
                cell.setBadgeCount(serial.unwatched)
            } else {
                cell.setBadgeCount(0)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: SMCatalogReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier, forIndexPath: indexPath) as! SMCatalogReusableView
        view.titleLabel.text = self.dataSource?.serialsCtl(self, titleForSection: indexPath.section)
        return view
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.serialsCtl(self, didSelectItemAtIndexPath: indexPath)
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var result = CGSizeZero
        if (self.mySerials) {
            result = CGSizeMake(self.view.bounds.size.width, 40)
        }
        return result
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var result = super.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
        if (!self.mySerials) {
            result = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        return result
    }
}
