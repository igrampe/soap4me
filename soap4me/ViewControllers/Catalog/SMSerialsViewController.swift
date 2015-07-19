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
}

class SMSerialsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let SMSerialCollectionCellIdentifier = "SMSerialCollectionCellIdentifier"
    let SMCatalogReusableViewIdentifier = "SMCatalogReusableViewIdentifier"
    
    weak var dataSource: SMSerialsViewControllerDataSource?
    weak var delegate: SMSerialsViewControllerDelegate?
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observe(selector: "didDrotateNotification", name: UIDeviceOrientationDidChangeNotification)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshTrigger", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl!)
        self.collectionView.alwaysBounceVertical = true
        
        self.collectionView.delegate = self
        self.collectionView.registerNib(UINib(nibName: "SMCatalogCollectionCell", bundle: nil), forCellWithReuseIdentifier: SMSerialCollectionCellIdentifier)
        self.collectionView.registerNib(UINib(nibName: "SMCatalogReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SMCatalogReusableViewIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SMCatalogManager.sharedInstance.apiGetSerialsMy()
    }

    func reloadUI() {
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func didDrotateNotification() {
        self.collectionView.reloadData()
    }
    
    func refreshTrigger() {
        SMCatalogManager.sharedInstance.apiGetSerialsMy()
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var result = 0
        if let n = self.dataSource?.numberOfSectionsForSerialsCtl(self) {
            result = n
        }
        return result
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        if let n = self.dataSource?.serialsCtl(self, numberOfObjectsInSection: section) {
            result = n
        }
        return result
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: SMCatalogCollectionCell  = collectionView.dequeueReusableCellWithReuseIdentifier(SMSerialCollectionCellIdentifier, forIndexPath: indexPath) as! SMCatalogCollectionCell
        cell.titleLabel.text = "Title \(indexPath.row)"
        
        var object = self.dataSource?.serialsCtl(self, objectAtIndexPath: indexPath)
        
        if let serial = object as? SMSerial {
            cell.titleLabel.text = serial.valueForKey("title_ru") as? String
            let sid = serial.valueForKey("sid") as! Int
            let urlStr = "\(HOST_URL)/assets/covers/soap/big/\(sid).jpg"
            if let url = NSURL(string: urlStr) {
                cell.imageView.sd_setImageWithURL(url)
            }
            let unwatched = serial.valueForKey("unwatched") as! Int
            cell.setBadgeCount(unwatched)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: SMCatalogReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: SMCatalogReusableViewIdentifier, forIndexPath: indexPath) as! SMCatalogReusableView
        view.titleLabel.text = self.dataSource?.serialsCtl(self, titleForSection: indexPath.section)
        return view
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.serialsCtl(self, didSelectItemAtIndexPath: indexPath)
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width: CGFloat = 0
        var columns: CGFloat = 0
        var isLandscape = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
        
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            columns = 2
            if isLandscape {
                columns += 1
            }
        case .Pad:
            columns = 4
            if isLandscape {
                columns += 2
            }
        default:
            break
        }
        
        width = (self.view.bounds.size.width - 8*(columns+1))/columns
        
        return CGSizeMake(width, width+8+41)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.bounds.size.width, 40)
    }
}
