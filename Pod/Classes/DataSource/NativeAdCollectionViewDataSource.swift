//
//  NativeAdCollectionViewDataSource.swift
//  PocketMediaNativeAds
//
//  Created by apple on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

@objc
public class NativeAdCollectionViewDataSource : NSObject, DisplayHelperDelegate, UICollectionViewDataSource {
  
  var collection : ReferenceArray?
  var nativeAdInjector : NativeAdInjector?
  var datasource : UITableViewDataSource?
  var displayHelper : DisplayHelperDelegate?
  
  required public init(datasource: UITableViewDataSource, displayHelper : DisplayHelperDelegate){
    super.init()
    collection = ReferenceArray()
    nativeAdInjector = NativeAdInjector(collection: self.collection!, displayHelper: self)
    self.datasource = datasource
    self.displayHelper = displayHelper
  }
  
  
  
  // Todo
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return -1
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
  
  
  public func onUpdateCollection() {
    displayHelper!.onUpdateCollection()
  }
  
  @objc public func requestAds(affiliateId: String , limit: UInt){
    NativeAdsRequest(affiliateId: affiliateId, delegate: self.nativeAdInjector!).retrieveAds(limit)
  }
  
}