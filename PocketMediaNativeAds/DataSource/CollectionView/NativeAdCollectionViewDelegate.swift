//
//  NativeAdTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

import UIKit

// @objc
// public class NativeAdCollectionViewDelegate: NSObject, UICollectionViewDelegate {
//
//    public var controller: UIViewController
//    public var delegate: UICollectionViewDelegate
//    public var datasource: NativeAdCollectionViewDataSource
//
//    required public init(datasource: NativeAdCollectionViewDataSource, controller: UIViewController, delegate: UICollectionViewDelegate) {
//        self.datasource = datasource
//        self.controller = controller
//        self.delegate = delegate
//    }
//
//    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//
//        if let val = datasource.adStream.isAdAtposition(indexPath.row) {
//            val.openAdUrl(controller)
//        } else {
//            return delegate.collectionView!(collectionView, didSelectItemAtIndexPath: indexPath)
//        }
//    }
//
// }
