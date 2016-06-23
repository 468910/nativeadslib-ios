//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

@objc
public class NativeAdTableViewDataSource : NSObject, UITableViewDataSource, DataSourceProtocol{
  
    public var datasource : UITableViewDataSource?
    public var tableView : UITableView?
    public var delegate : UITableViewDelegate?
    public var controller : UIViewController?
    public var adStream : NativeAdStream
  
  
  
  
  
  public func onUpdateDataSource() {
    tableView?.reloadData()
  }
  
  public func numberOfElements() -> Int {
    return datasource!.tableView(tableView!, numberOfRowsInSection: 0)
  }
  
  
  

  @objc
  public required init(controller : UIViewController, tableView: UITableView, adStream : NativeAdStream){
    
    self.controller = controller
    self.adStream = adStream
    
    
    
    self.datasource = tableView.dataSource
    self.tableView = tableView
    
    
    super.init()
    
   
    
    
    self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
    
    tableView.delegate = self.delegate
    tableView.dataSource = self
    
    
    
    
    
    
    if((tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell")) == nil){
        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
    }
    
 
    }
  
    // Data Source
    @objc
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let val = adStream.isAdAtposition(indexPath.row){
          NSLog("Insert AD at index %d", indexPath.row)
        let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
        cell.configureAdView(val)
        return cell;
      }else{
          NSLog("This is a normal Item before normalization %d", indexPath.row)
        return datasource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: adStream.normalize(indexPath.row), inSection: 0))
        }
      
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource!.tableView(tableView, numberOfRowsInSection: section) + adStream.getAdCount()
    }
  
  
  
  
 

  

   
  

    
}


