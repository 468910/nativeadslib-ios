//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Kees Bank on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

/**
 Example of the AdStream used with an TableView
 **/
class TableViewWithSectionsController: UITableViewController {
    
    var tableViewDataSource: ExampleTableViewDataSourceWithSections?
    var stream: NativeAdStream?
    
    override func viewDidLoad() {
        self.title = "TableView"
        
        tableViewDataSource = ExampleTableViewDataSourceWithSections()
        tableViewDataSource?.loadLocalJSON()
        tableView.dataSource = tableViewDataSource
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        //PocketMedia add ads
        stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165") /* replace with your own token!! */
        stream?.requestAds(10)//Add 5 ads
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.indexPathForSelectedRow
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        stream?.reloadAds()
        refreshControl.endRefreshing()
    }
}
