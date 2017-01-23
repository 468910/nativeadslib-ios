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
        tableViewDataSource = ExampleTableViewDataSourceWithSections()
        tableViewDataSource?.loadLocalJSON()
        tableView.dataSource = tableViewDataSource
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.refresh(refreshControl:)), for: UIControlEvents.valueChanged)

        let customXib = UINib.init(nibName: "CustomAd", bundle: nil)

        // PocketMedia add ads
        stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", customXib: customXib, adPosition: MarginAdPosition(margin: 4)) /* replace with your own token!! */
        stream?.requestAds(10) // Add 10 ads

        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func refresh(refreshControl: UIRefreshControl) {
        stream?.reloadAds()
        refreshControl.endRefreshing()
    }
}
