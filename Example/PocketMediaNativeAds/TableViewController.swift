//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Kees Bank on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class TableViewController: UITableViewController {
  
    var tableViewDataSource : ExampleTableViewDataSource?
  
    override func viewDidLoad() {
      
      super.viewDidLoad()
      tableViewDataSource = ExampleTableViewDataSource()
      tableViewDataSource!.loadLocalJSON()
      tableView.dataSource = tableViewDataSource
      
      
    var stream = NativeAdStream(controller: self, tableView: self.tableView, adFrequency: 1)
     stream.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
    }
    
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80
  }
    
 
  
  
  
    
}

