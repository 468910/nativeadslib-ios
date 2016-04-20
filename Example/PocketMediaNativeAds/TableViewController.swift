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
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        //tableViewDataSource = NativeAdTableViewDataSource(datasource: self, tableView: self.tableView, delegate: self, controller: self)
        super.viewDidLoad()
      tableViewDataSource = ExampleTableViewDataSource()
        self.tableView.dataSource = tableViewDataSource
      
    tableViewDataSource!.loadLocalJSON()
      self.tableView.reloadData()
        
      
        //loadLocalJSON()
        //tableViewDataSource?.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 5)
    }
    
  
   
    
 
  
  
  
    
}

