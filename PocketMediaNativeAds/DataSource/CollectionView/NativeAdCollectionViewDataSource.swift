//
//  NativeAdCollectionViewDataSource.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

/**
 Wraps around a datasource so it contains both a mix of ads and none ads.
 */
@objc
public class NativeAdCollectionViewDataSource: DataSource, UICollectionViewDataSource, UICollectionViewDataSourceWrapper {
    /// Original datasource.
    open var datasource: UICollectionViewDataSource
    /// Original tableView.
    open var collectionView: UICollectionView
    /// Original deglegate.
    open var delegate: UICollectionViewDelegate?
    // Ad position logic.
    fileprivate var adPosition: AdPosition

    /**
     Hijacks the sent delegate and datasource and make it use our wrapper. Also registers the ad unit we'll be using.
     - parameter controller: The controller to create NativeAdTableViewDelegate
     - parameter tableView: The tableView this datasource is attached to.
     - parameter adPosition: The instance that will define where ads are positioned.
     */
    @objc
    public required init(controller: UIViewController, collectionView: UICollectionView, adPosition: AdPosition, customXib: UINib?) {
        if collectionView.dataSource == nil {
            preconditionFailure("Your tableview must have a dataSource set before use.")
        }
        self.datasource = collectionView.dataSource!
        self.adPosition = adPosition
        self.collectionView = collectionView
        super.init(type: AdUnit.UIType.CollectionView, customXib: customXib, adPosition: adPosition)
        // TODO: Swizzle

        // Hijack the delegate and datasource and make it use our wrapper.
        if collectionView.delegate != nil {
            self.delegate = NativeAdCollectionViewDelegate(datasource: self, controller: controller, delegate: collectionView.delegate!)
            collectionView.delegate = self.delegate
        }
        collectionView.dataSource = self
    }

    /**
     Reset the datasource. if this wrapper is deinitialized.
     */
    deinit {
        self.collectionView.dataSource = datasource
    }

    /**
     This function checks if we have a cell registered with that name. If not we'll register it.
     */
    public override func registerNib(nib: UINib?, identifier: String) {
        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        let registerNib = nib == nil ? UINib(nibName: identifier, bundle: bundle) : nib
        collectionView.register(registerNib, forCellWithReuseIdentifier: identifier)
    }

    /**
     Return the cell of a identifier.
     */
    public override func dequeueReusableCell(identifier: String, indexPath: IndexPath) -> UIView {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    /**
     Required. Asks your data source object for the number of items in the specified section.
     */
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let value = datasource.collectionView(collectionView, numberOfItemsInSection: section)
        if let ads = adListingsPerSection[section]?.count {
            return value + ads
        }
        return value
    }

    /**
     From: DataSourceProtocol
     Return the number of rows in a particular section. If you're implementing a datasource that doesn't support sections, just ignore the section parameter.
     - Important:
     Call the original data source to get the count. Do NOT sum the original amount + ads
     */
    public override func numberOfRowsInSection(section: Int) -> Int {
        return datasource.collectionView(collectionView, numberOfItemsInSection: section)
    }

    /**
     Asks your data source object for the number of sections in the collection view.
     */
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let result = datasource.numberOfSections?(in: collectionView) {
            return result
        }
        return 1
    }

    /**
     From: DataSourceProtocol
     Return the number of sections. If you're implementing a datasource that doesn't support sections, just return 1.
     - Important:
     Call the original data source to get the count.
     */
    public override func numberOfSections() -> Int {
        return numberOfSections(in: collectionView)
    }

    /**
     Asks your data source object for the cell that corresponds to the specified item in the collection view.
     */
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let listing = getNativeAdListing(indexPath) {
            return getAdCell(listing.ad, indexPath: indexPath) as! UICollectionViewCell
        }
        return datasource.collectionView(collectionView, cellForItemAt: getOriginalPositionForElement(indexPath))
    }

    /**
     Asks your data source object to provide a supplementary view to display in the collection view.
     */
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let cell = datasource.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) {
            return cell
        }
        return UICollectionReusableView()
    }

    /**
     Asks your data source object whether the specified item can be moved to another location in the collection view.
     */
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if let result = datasource.collectionView?(collectionView, canMoveItemAt: indexPath) {
            return result
        }
        return false
    }

    /**
     Tells your data source object to move the specified item to its new location.
     */
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        datasource.collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }

    /**
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     Abstract classes that a datasource should override. It's specific to the type of data source.
     */
    open override func onAdRequestSuccess(_ ads: [NativeAd]) {
        super.onAdRequestSuccess(ads)
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    open override func reloadRowsAtIndexPaths(indexPaths: [IndexPath], animation: Bool) {
        
    }
}
