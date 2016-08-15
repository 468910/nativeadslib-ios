//
//  NativeAdCollectionViewDataSource.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

@objc
public class NativeAdCollectionViewDataSource: NSObject, UICollectionViewDataSource, DataSourceProtocol {

	public var datasource: UICollectionViewDataSource?
	public var collectionView: UICollectionView?
	public var delegate: UICollectionViewDelegate?
	public var controller: UIViewController?
	public var adStream: NativeAdStream

	public func onUpdateDataSource() {
		collectionView!.reloadData()
	}

	public func numberOfElements() -> Int {
		return datasource!.collectionView(collectionView!, numberOfItemsInSection: 0)
	}
  
  public func detachFromView() {
    
  }
  
  public func attachAdStream(adStream: NativeAdStream) {
  }

	required public init(controller: UIViewController, collectionView: UICollectionView, adStream: NativeAdStream) {
		self.datasource = collectionView.dataSource
		self.controller = controller
		self.collectionView = collectionView
		self.adStream = adStream
		super.init()

		self.delegate = NativeAdCollectionViewDelegate(datasource: self, controller: controller, delegate: collectionView.delegate!)

		collectionView.delegate = self.delegate
		collectionView.dataSource = self

		let bundle = PocketMediaNativeAdsBundle.loadBundle()!
		collectionView.registerNib(UINib(nibName: "NativeAdCollectionCell", bundle: bundle), forCellWithReuseIdentifier: "NativeAdCollectionCell")

	}

	public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if let val = adStream.isAdAtposition(indexPath.row) {
			NSLog("Insert AD at index %d", indexPath.row)
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NativeAdCollectionCell", forIndexPath: indexPath) as! NativeAdCollectionCell

			cell.configureAdView(val)
			return cell
		} else {
			NSLog("This is a normal Item before normalization %d", indexPath.row)
			return datasource!.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forRow: adStream.normalize(indexPath.row), inSection: 0))
		}
	}

	// Todo
	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasource!.collectionView(collectionView, numberOfItemsInSection: section) + adStream.getAdCount()
	}

}
