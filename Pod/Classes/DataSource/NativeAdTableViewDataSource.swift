//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

@objc
public class NativeAdTableViewDataSource : NSObject, UITableViewDataSource, DisplayHelperDelegate{
    
    public var collection : ReferenceArray!
    public var nativeAdInjector : NativeAdInjector?
    public var datasource : UITableViewDataSource?
    public var tableView : UITableView?

    @objc
    required public init(datasource: UITableViewDataSource, tableView : UITableView){
        super.init()
        collection = ReferenceArray()
        nativeAdInjector = NativeAdInjector(collection: self.collection!, displayHelper: self)
        self.datasource = datasource
        self.tableView = tableView
        self.tableView!.dataSource = self
        
        
        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
      
        tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
        
        tableView.registerNib(UINib(nibName: "NativeAdCell", bundle: bundle), forCellReuseIdentifier: "NativeAdCell")
    }
    
    // Data Source
    @objc
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     // print("1: indexForRow = " + String(indexPath.row))
      print("2: Original indexForRow =" + String(indexPath.row))
 
        if (collection!.collection[indexPath.row] is NativeAd){
          
            let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdCell") as! NativeAdCell
            cell.configureAdView(collection!.collection[indexPath.row] as! NativeAd)
           print("Inject NativeAd")
          
          
          
          
            return cell;
        }else{
            // TODO: request content with the index in the original datasource, not in the merged one.
          let truePath = NSIndexPath(forRow: indexPath.row - (indexPath.row / self.nativeAdInjector!.adMargin!), inSection : 0 )
          
          if((indexPath.row / self.nativeAdInjector!.adMargin!) > self.nativeAdInjector!.adInjected!) {
            let secondPath = NSIndexPath(forRow: indexPath.row + 1 - (indexPath.row / self.nativeAdInjector!.adMargin!), inSection: 0)
            return datasource!.tableView(tableView, cellForRowAtIndexPath : secondPath)
          }
          print("MOdified row index" +  String(indexPath.row - (indexPath.row / self.nativeAdInjector!.adMargin!)))
            // Dirty fix 
            return datasource!.tableView(tableView, cellForRowAtIndexPath: truePath)
          
        }
      
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection!.collection.count
    }
    
    @objc
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      print("Is this even invoked")
        if let ad = collection!.collection[indexPath.row] as? NativeAd{
            print("Opening url: \(ad.clickURL.absoluteString)")
            // This method will take of opening the ad inside of the app, until we have an iTunes url
            //ad.openAdUrl(self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @objc
    public func onUpdateCollection() {
        tableView!.onUpdateCollection()
    }
    
  
   @objc public func requestAds(affiliateId: String , limit: UInt){
      NativeAdsRequest(affiliateId: affiliateId, delegate: self.nativeAdInjector!).retrieveAds(limit)
   }
    
    
    
}

extension UITableView : DisplayHelperDelegate {
    public func onUpdateCollection() {
        self.reloadData()
    }
}