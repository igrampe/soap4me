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
    var refreshControlContainer: UIView!
    
    let cellIdentifier = "cellIdentifier"
    let headerIdentifier = "headerIdentifier"
    
    var imgsUrls = [Int:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControlContainer = UIView(frame: CGRectMake(0, 0, 0, 0))
        self.collectionView.addSubview(self.refreshControlContainer)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshTrigger", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControlContainer.addSubview(self.refreshControl!)
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
    
    func layoutOffset() {
        var offset: CGFloat = 0
        if let navCtl = self.navigationController {
            offset = 44+20
        }
        self.collectionView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(offset, 0, 0, 0)
    }
    
    func didRotateNotification() {
        self.collectionView.reloadData()
        self.layoutOffset()
    }
    
    func refreshTrigger() {
        self.obtainData()
    }
    
    func obtainData() {
        
    }
    
    func reloadData() {
        
    }
    
    func reloadUI() {
        self.layoutOffset()
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
        var isLandscape = UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight
        
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
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 8)
    }
}
