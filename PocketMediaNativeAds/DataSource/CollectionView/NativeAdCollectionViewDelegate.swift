//
//  NativeAdTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

import UIKit

@objc
public class NativeAdCollectionViewDelegate: NSObject, UICollectionViewDelegate {

    public var controller: UIViewController
    public var delegate: UICollectionViewDelegate
    public var datasource: NativeAdCollectionViewDataSource

    public required init(datasource: NativeAdCollectionViewDataSource, controller: UIViewController, delegate: UICollectionViewDelegate) {
        self.datasource = datasource
        self.controller = controller
        self.delegate = delegate
    }

    /**
     Tells the delegate that the item at the specified index path was selected.
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let val = datasource.getNativeAdListing(indexPath) {
            val.ad.openAdUrl(opener: FullScreenBrowser(parent: controller))
            return
        }
        delegate.collectionView?(collectionView, didSelectItemAt: self.datasource.getOriginalPositionForElement(indexPath))
    }
}
