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
// @objc
// public class NativeAdCollectionViewDataSource: DataSource, UICollectionViewDataSource {
//
//    /// Original datasource.
//    open var datasource: UICollectionViewDataSource
//    /// Original tableView.
//    open var tableView: UITableView
//    /// Original deglegate.
//    open var delegate: NativeAdTableViewDelegate?
//    // Ad position logic.
//    fileprivate var adPosition: AdPosition
//
//    /**
//     Hijacks the sent delegate and datasource and make it use our wrapper. Also registers the ad unit we'll be using.
//     - parameter controller: The controller to create NativeAdTableViewDelegate
//     - parameter tableView: The tableView this datasource is attached to.
//     - parameter adPosition: The instance that will define where ads are positioned.
//     */
//    @objc
//    public required init(controller: UIViewController, collectionView: UICollectionView, adPosition: AdPosition) {
//        if collectionView.dataSource == nil {
//            preconditionFailure("Your tableview must have a dataSource set before use.")
//        }
//        self.datasource = collectionView.dataSource!
//        self.adPosition = adPosition
//        self.tableView = tableView
//        super.init()
//        //TODO: Swizzle
//
//        // Hijack the delegate and datasource and make it use our wrapper.
//        if tableView.delegate != nil {
//            self.delegate = NativeAdCollectionViewDelegate(datasource: self, controller: controller, delegate: collectionView.delegate!)
//            tableView.delegate = self.delegate
//        }
//        tableView.dataSource = self
//
//        if adUnitType == .custom {
//            if tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil {
//                preconditionFailure("Something went wrong here. CustomAdCell should've already been registered at the NativeAdStream class or when doing a custom integration by the host app.")
//            }
//        } else {
//            // Register the ad unit we'll be using.
//            registerAdUnit(name: adUnitType.nibName)
//        }
//
//        collectionView.delegate = self.delegate
//        collectionView.dataSource = self
//    }
//
//    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        if let val = adStream.isAdAtposition(indexPath.row) {
//            NSLog("Insert AD at index %d", indexPath.row)
//            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NativeAdCollectionCell", forIndexPath: indexPath) as! NativeAdCollectionCell
//
//            cell.configureAdView(val)
//            return cell
//        } else {
//            NSLog("This is a normal Item before normalization %d", indexPath.row)
//            return datasource!.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forRow: adStream.normalize(indexPath.row), inSection: 0))
//        }
//    }
//
//    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return datasource!.collectionView(collectionView, numberOfItemsInSection: section) + adStream.getAdCount()
//    }
//
//    public func onUpdateDataSource() {
//        collectionView!.reloadData()
//    }
//
//    public func numberOfElements() -> Int {
//        return datasource!.collectionView(collectionView!, numberOfItemsInSection: 0)
//    }
//
// }
