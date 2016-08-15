//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

@objc
public class NativeAdTableViewDataSource: NSObject, UITableViewDataSource, DataSourceProtocol {

	public var datasource: UITableViewDataSource?
	public var tableView: UITableView?
	public var delegate: UITableViewDelegate?
	public var controller: UIViewController?
    weak public var adStream: NativeAdStream?
    public typealias completionBlock = () ->  ()
    public var completion : completionBlock?
    public var oldDelegate : UITableViewDelegate?

	public func onUpdateDataSource() {
		tableView!.reloadData()
	}

	public func numberOfElements() -> Int {
		return datasource!.tableView(tableView!, numberOfRowsInSection: 0)
	}

	func handleRefresh(refreshControl: UIRefreshControl) {

		refreshControl.endRefreshing()
	}
  
  public func attachAdStream(adStream : NativeAdStream){
    self.adStream = adStream
    tableView!.reloadData()
  }
  

   deinit{
     NativeAdStream.viewRegister = NativeAdStream.viewRegister.filter{$0 != String(ObjectIdentifier(tableView!))}
     self.tableView!.dataSource = datasource
     self.tableView!.delegate = oldDelegate
    
   }

	@objc
	public required init(controller: UIViewController, tableView: UITableView, adStream: NativeAdStream) {
      
     
      
		self.controller = controller
		self.adStream = adStream

		self.datasource = tableView.dataSource
		self.tableView = tableView
		self.tableView?.rowHeight = UITableViewAutomaticDimension
		self.tableView?.estimatedRowHeight = 180.0

		super.init()

		self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
      
        self.oldDelegate = tableView.delegate!
		tableView.delegate = self.delegate
		tableView.dataSource = self

		// Check the kind of cell to use

		if ((tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell")) == nil && adStream.adUnitType == .Standard) {
			let bundle = PocketMediaNativeAdsBundle.loadBundle()!
			tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
		}

		if ((tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell")) == nil && adStream.adUnitType == .Big) {
			let bundle = PocketMediaNativeAdsBundle.loadBundle()!
			tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
		}

	}
  
  

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if((completion) != nil){
        completion!()
        print("Completion has been invoked")
        completion = nil
      }
      
      
		if let val = adStream!.isAdAtposition(indexPath.row) {
			if (adStream!.adUnitType == .Standard) {
				let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
				cell.configureAdView(val)
				return cell;
			} else {
				let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
				cell.configureAdView(val)
				return cell;
			}
		} else {
			return datasource!.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: adStream!.normalize(indexPath.row), inSection: indexPath.section))
		}

	}

	@objc
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return datasource!.numberOfSectionsInTableView!(tableView)
	}

	@objc
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datasource!.tableView(tableView, numberOfRowsInSection: section) + adStream!.getAdCount()
	}

}
