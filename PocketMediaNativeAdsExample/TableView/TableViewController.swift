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
class TableViewController: UITableViewController {

	var tableViewDataSource: ExampleTableViewDataSource?
	var stream: NativeAdStream?

	override func viewDidLoad() {
		self.title = "TableView"

		super.viewDidLoad()
		tableViewDataSource = ExampleTableViewDataSource()
		tableViewDataSource?.loadLocalJSON()
		tableView.dataSource = tableViewDataSource

		_ = UINib(nibName: "TestSupplied", bundle: nil)

		self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
		_ = [5, 2, 4, 99]
		stream = NativeAdStream(controller: self, mainView: self.tableView, adMargin: 1, firstAdPosition: 5)
		stream!.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.indexPathForSelectedRow
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 80
	}

	func handleRefresh(refreshControl: UIRefreshControl) {
		stream?.clearAdStream("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
		refreshControl.endRefreshing()
	}
}
