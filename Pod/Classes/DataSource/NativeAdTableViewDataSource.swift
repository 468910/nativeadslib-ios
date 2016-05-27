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
  
    public var datasource : UITableViewDataSource?
    public var tableView : UITableView?
    public var delegate : UITableViewDelegate?
    public var controller : UITableViewController?
    public var adStream : NativeAdStream?
  
  
  
  
  
  
  
  

  @objc
  public required init(datasource: UITableViewDataSource, tableView : UITableView, delegate : UITableViewDelegate, controller : UITableViewController){
        super.init()
  
       self.controller = controller
  
      adStream = NativeAdStream(adFrequency: 4, datasource: self, delegate: self)
    
    
        self.datasource = datasource
        self.tableView = tableView
    
    
    
    
      self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: delegate)
    
      tableView.delegate = self.delegate
      tableView.dataSource = self
    
      
        
        
        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
      
        tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
        
        tableView.registerNib(UINib(nibName: "NativeAdCell", bundle: bundle), forCellReuseIdentifier: "NativeAdCell")
 
    }
  
    // Data Source
    @objc
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     NSLog("True index: %d", indexPath.row)
      if let val = adStream!.isAdAtposition(indexPath.row){
        NSLog("Native ad")
        let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdCell") as! NativeAdCell
        cell.configureAdView(val)
        return cell;
      }else{
        NSLog("Normalized :  %d", adStream!.normalize(indexPath.row))
        return datasource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: adStream!.normalize(indexPath.row), inSection: 0))
        }
      
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource!.tableView(tableView, numberOfRowsInSection: section) + adStream!.getAdCount()
    }
  
  public func getOriginalCollectionCount() -> Int{
      return datasource!.tableView(tableView!, numberOfRowsInSection: 0)
  }

  
  
    @objc
    public func onUpdateCollection() {
        tableView!.onUpdateCollection()
    }
    
  
   @objc public func requestAds(affiliateId: String , limit: UInt){
      NativeAdsRequest(adPlacementToken: affiliateId, delegate: adStream!).retrieveAds(limit)
   }
  

    
}

extension UITableView : DisplayHelperDelegate {
    public func onUpdateCollection() {
        self.reloadData()
    }
}