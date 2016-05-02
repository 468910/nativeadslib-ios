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
    public var ads : ReferenceArray?
  
    public var nativeAdInjector : NativeAdsRetriever?
    public var datasource : UITableViewDataSource?
    public var tableView : UITableView?
    public var delegate : UITableViewDelegate?
    public var controller : UITableViewController?
  
  
  
  
  
  

  
    @objc
  public required init(datasource: UITableViewDataSource, tableView : UITableView, delegate : UITableViewDelegate, controller : UITableViewController){
        super.init()
  
       self.controller = controller
  
        collection =  ReferenceArray()
    
        self.ads = ReferenceArray()
        nativeAdInjector = NativeAdsRetriever(ads: ads!, displayHelper: self)
    
    
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
      
      
      let fullCount = datasource!.tableView(tableView, numberOfRowsInSection: 0) + ads!.collection.count
      
      var adMargin = fullCount / ads!.collection.count
      
       print("Current row" + String(indexPath.row))
       print("AdMargin" + String(adMargin))
       if ((indexPath.row % adMargin) == 0 && indexPath.row > 0 ){
          
            let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdCell") as! NativeAdCell
            print(indexPath.row / adMargin)
            cell.configureAdView(ads!.collection[indexPath.row / adMargin - 1] as! NativeAd)
        
          
          
          
            return cell;
        }else{
            // TODO: request content with the index in the original datasource, not in the merged one.
        let truePath = NSIndexPath(forRow: indexPath.row - (indexPath.row / adMargin), inSection : 0 )
        print(ads!.collection.count)
        
        if(truePath.row == datasource!.tableView(tableView, numberOfRowsInSection: 0)){
        let cell : NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdCell") as! NativeAdCell
        cell.configureAdView(ads!.collection.last as! NativeAd)
           dump(ads!.collection)
            return cell
        }
        /**
          if((indexPath.row / self.nativeAdInjector!.adMargin!) > ) {
            let secondPath = NSIndexPath(forRow: indexPath.row + 1 - (indexPath.row / adMargin), inSection: 0)
            return datasource!.tableView(tableView, cellForRowAtIndexPath : secondPath)
          }*/
          
       // print("MOdified row index" +  String(indexPath.row - (indexPath.row / self.nativeAdInjector!.adMargin!)))
            // Dirty fix 
        
          return datasource!.tableView(tableView, cellForRowAtIndexPath: truePath)
        }
      
    }
    
    
    @objc
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource!.tableView(tableView, numberOfRowsInSection: section) + ads!.collection.count
    }
  
  
 
    
    @objc
    public func onUpdateCollection() {
        tableView!.onUpdateCollection()
    }
    
  
   @objc public func requestAds(affiliateId: String , limit: UInt){
      NativeAdsRequest(adPlacementToken: affiliateId, delegate: self.nativeAdInjector!).retrieveAds(limit)
   }
    
    
    
}

extension UITableView : DisplayHelperDelegate {
    public func onUpdateCollection() {
        self.reloadData()
    }
}