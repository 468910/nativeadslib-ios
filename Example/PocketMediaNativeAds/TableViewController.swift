//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class TableViewController: UITableViewController {
  
    var tableViewDataSource : ExampleTableViewDataSource?
    var nativeAd : NativeAdTableViewDataSource?
  
    override func viewDidLoad() {
      
        super.viewDidLoad()
      tableViewDataSource = ExampleTableViewDataSource()
      tableViewDataSource!.loadLocalJSON()
      
      
      nativeAd = NativeAdTableViewDataSource(datasource: tableViewDataSource!, tableView: self.tableView, delegate: self, controller: self)
      self.tableView.dataSource = nativeAd
      
      nativeAd!.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 5)
    }
    
  
   
    
 
  
  
  
    
}

