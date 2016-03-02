//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class NativeAdTableViewDataSource : NSObject, UITableViewDataSource, DisplayHelperDelegate {
  
  var collection : ReferenceArray<Any>?
  var nativeAdInjector : NativeAdInjector?
  var datasource : UITableViewDataSource?
  var displayHelper : DisplayHelperDelegate?
  
  required public init(datasource: UITableViewDataSource, displayHelper : DisplayHelperDelegate){
    super.init()
    collection = ReferenceArray<Any>()
    nativeAdInjector = NativeAdInjector(collection: self.collection!, displayHelper: self)
    self.datasource = datasource
    self.displayHelper = displayHelper
  }
  
  // Data Source
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  print("Injector: cellforRowAtindexPath")
  if (collection!.collection[indexPath.row] is NativeAd){
    print("Native ad Cell")
  let cell = NSBundle.mainBundle().loadNibNamed("NativeAdCell", owner: self, options: nil).first as! NativeAdCell
  cell.configureFromNativeAd(collection!.collection[indexPath.row] as! NativeAd)
  return cell;
  }else{
    
  return datasource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
  }
  }
  
  
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  return collection!.collection.count
  }
  
  public func onUpdateCollection() {
    displayHelper!.onUpdateCollection()
  }
  
  @objc public func requestAds(nativeAdsRequest: NativeAdsRequest, limit: UInt){
    nativeAdsRequest.retrieveAds(limit)
  }
  
}