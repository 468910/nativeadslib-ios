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
    
    public var collection : ReferenceArray<Any>!
    public var nativeAdInjector : NativeAdInjector?
    public var datasource : UITableViewDataSource?
    public var tableView : UITableView?
    
    @objc
    required public init(datasource: UITableViewDataSource, tableView : UITableView){
        super.init()
        collection = ReferenceArray<Any>()
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
        print("Injector: cellforRowAtindexPath")
        if (collection!.collection[indexPath.row] is NativeAd){
            print("Native ad Cell")
            let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdCell") as! NativeAdCell
            cell.configureAdView(collection!.collection[indexPath.row] as! NativeAd)
            return cell;
        }else{
            // TODO: request content with the index in the original datasource, not in the merged one.
            return datasource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection!.collection.count
    }
    
    @objc
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    @objc public func requestAds(nativeAdsRequest: NativeAdsRequest, limit: UInt){
        nativeAdsRequest.retrieveAds(limit)
    }
    
    
    
    
}

extension UITableView : DisplayHelperDelegate {
    public func onUpdateCollection() {
        self.reloadData()
    }
}