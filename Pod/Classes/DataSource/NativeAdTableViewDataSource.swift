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
    public var controller : UITableViewController?
  public var adStream : NativeAdStream
  
  
  
  
  
  public func onUpdateDataSource() {
    onUpdateCollection()
  }
  
  public func numberOfElements() -> Int {
    return datasource!.tableView(tableView!, numberOfRowsInSection: 0)
  }
  
  
  

  @objc
  public required init(controller : UITableViewController, adStream : NativeAdStream){
    
    self.controller = controller
    self.adStream = adStream
    
    
    
    self.datasource = controller.tableView!.dataSource
    self.tableView = controller.tableView!
    
    
    super.init()
    
   
    
    
    self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: controller.tableView!.delegate!)
    
    controller.tableView.delegate = self.delegate
    controller.tableView.dataSource = self
    
    
    
    
    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
    
    controller.tableView!.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
    
    controller.tableView!.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdView")
 
    }
  
    // Data Source
    @objc
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let val = adStream.isAdAtposition(indexPath.row){
        let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdView") as! NativeAdCell
        cell.configureAdView(val)
        return cell;
      }else{
        return datasource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: adStream.normalize(indexPath.row), inSection: 0))
        }
      
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource!.tableView(tableView, numberOfRowsInSection: section) + adStream.getAdCount()
    }
  
  
 

  
  
    @objc
    public func onUpdateCollection() {
        tableView!.onUpdateCollection()
    }
    
  
   
  

    
}

extension UITableView : DisplayHelperDelegate {
    public func onUpdateCollection() {
        self.reloadData()
    }
}