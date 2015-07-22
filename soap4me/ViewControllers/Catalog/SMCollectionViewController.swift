//
//  SMCollectionViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 22/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import SDWebImage

class SMCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    let cellIdentifier = "cellIdentifier"
    let headerIdentifier = "headerIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshTrigger", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl!)
        self.collectionView.alwaysBounceVertical = true
        
        self.collectionView.delegate = self
        self.collectionView.registerNib(UINib(nibName: "SMCatalogCollectionCell", bundle: nil), forCellWithReuseIdentifier: self.cellIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.observe(selector: "didRotateNotification", name: UIDeviceOrientationDidChangeNotification)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.stopObserve()
    }
    
    func didRotateNotification() {
        self.collectionView.reloadData()
    }
    
    func refreshTrigger() {
        self.obtainData()
    }
    
    func obtainData() {
        
    }
    
    func reloadData() {
        
    }
    
    func reloadUI() {
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var result = 0
        return result
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        return result
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: SMCatalogCollectionCell  = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! SMCatalogCollectionCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier, forIndexPath: indexPath) as! UICollectionReusableView
        return view
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
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
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
