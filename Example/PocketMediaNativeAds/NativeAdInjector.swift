//
//  NativeAdInjector.swift
//  PocketMediaNativeAds
//
//  Created by apple on 01/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import PocketMediaNativeAds

public class NativeAdInjector : NSObject, NativeAdsConnectionDelegate, UITableViewDataSource{
  
  public var collection : [Any]
  public var datasource : UITableViewDataSource
  public var delegate : DisplayHelperDelegate
  
  public required init(displayHelper: DisplayHelperDelegate, datasource : UITableViewDataSource){
    delegate = displayHelper
    self.datasource = datasource
    collection = [Any]()
  }
  
  @objc public func requestAds(nativeAdsRequest: NativeAdsRequest, limit: UInt){
     nativeAdsRequest.retrieveAds(limit)
  }
  
  
  @objc public func didRecieveError(error: NSError) {
    
  }
  
  @objc public func didRecieveResults(nativeAds: [NativeAd]) {
    nativeAds.forEach {
       print("insert add")
       collection.insert($0, atIndex: Int(arc4random_uniform(UInt32(collection.count))))
    }
    delegate.onUpdateCollection()
  }
  
  @objc public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
 
  // Data Source
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    print("Injector: cellforRowAtindexPath")
    if (collection[indexPath.row] is NativeAd){
      let cell = NSBundle.mainBundle().loadNibNamed("NativeAdCell", owner: self, options: nil).first as! NativeAdCell
      cell.configureFromNativeAd(collection[indexPath.row] as! NativeAd)
      return cell;
    }else{
      return datasource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
  }
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   return collection.count
  }
  
}