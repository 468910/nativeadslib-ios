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
public class NativeAdTableViewDataSource: NSObject, UITableViewDataSource, NativeAdTableViewDataSourceProtocol {

	public var datasource: UITableViewDataSource
	public var tableView: UITableView
	public var delegate: NativeAdTableViewDelegate?
	public var controller: UIViewController
    //TODO: Check if this still creates a memory leak.
	public var adStream: NativeAdStream //This used to be optional + weak to stop memory leaks.
	public typealias completionBlock = () -> ()
	public var completion: completionBlock?
	public var oldDelegate: UITableViewDelegate?

	public func onUpdateDataSource() {
		tableView.reloadData()
	}

	public func numberOfElements() -> Int {
		var numOfRows = 0
		for i in 0...max(0, datasource.numberOfSectionsInTableView!(tableView) - 1) {
			numOfRows += datasource.tableView(tableView, numberOfRowsInSection: i)
		}
		return numOfRows
	}

	// TODO: Maybe this can be improved after futher testing
	public func getTruePosistionInDataSource(indexPath: NSIndexPath) -> Int {
		return IndexRowNormalizer.getTruePosistionForIndexPath(indexPath, datasource: self)
	}

	func handleRefresh(refreshControl: UIRefreshControl) {
		refreshControl.endRefreshing()
	}

	public func attachAdStream(adStream: NativeAdStream) {
		self.adStream = adStream
		tableView.reloadData()
	}

	deinit {
		NativeAdStream.viewRegister = NativeAdStream.viewRegister.filter { $0 != String(ObjectIdentifier(tableView)) }
		self.tableView.dataSource = datasource
		self.tableView.delegate = oldDelegate
	}

	@objc
	public required init(controller: UIViewController, tableView: UITableView, adStream: NativeAdStream) {
		self.controller = controller
		self.adStream = adStream
		self.datasource = tableView.dataSource!
		self.tableView = tableView
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 180.0
		super.init()
		self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
		self.oldDelegate = tableView.delegate!
		tableView.delegate = self.delegate
		tableView.dataSource = self

		// Check the kind of cell to use
		switch (adStream.adUnitType) {
		case .Custom:
			if (tableView.dequeueReusableCellWithIdentifier("CustomAdCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
				adStream.adUnitType = .Standard
			}
			break
		case .Big:
			if (tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
			}
			break
		default:
			if (tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
			}
			break
		}
	}

	public func getAdCellForTableView(nativeAd: NativeAd) -> UITableViewCell {
		switch (adStream.adUnitType) {
		case .Custom:
			let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("CustomAdCell") as! NativeAdCell
			cell.configureAdView(nativeAd)
			return cell;
		case .Big:
			let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
			cell.configureAdView(nativeAd)
			return cell;
		default:
			let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
			cell.configureAdView(nativeAd)
			return cell;
		}
	}

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if ((completion) != nil) {
			completion!()
			print("Completion has been invoked")
			completion = nil
		}

		if let val = adStream.isAdAtposition(indexPath) {
			return getAdCellForTableView(val)
		} else {
//			var temp = adStream!.normalize(indexPath)
			return datasource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: adStream.normalize(indexPath), inSection: indexPath.section))
		}

	}

	public func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int {
		return tableView(tableView, numberOfRowsInSection: section)
	}

	@objc
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var totalRows = 0

		for i in (0...section) {
			let rowsInSection = datasource.tableView(tableView, numberOfRowsInSection: i)
			totalRows += rowsInSection
		}

		return adStream.getCountForSection(datasource.tableView(tableView, numberOfRowsInSection: section), totalRowsInSection: totalRows)
	}

	public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForHeaderInSection: section) {
			return string
		} else {
			return nil
		}
	}

	public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForFooterInSection: section) {
			return string
		} else {
			return nil
		}
	}

	public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if (respondsToSelector(Selector("tableView:canEditRowAtIndexPath"))) {
			return datasource.tableView!(tableView, canEditRowAtIndexPath: indexPath)
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if (respondsToSelector(Selector("tableView:canMoveRowAtIndexPath"))) {
			return datasource.tableView!(tableView, canEditRowAtIndexPath: indexPath)
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
		if (respondsToSelector(Selector("tableView:sectionForSectionIndexTitle"))) {
			return datasource.tableView!(tableView, sectionForSectionIndexTitle: title, atIndex: index)
		} else {
			return 0
		}
	}

	public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		if (respondsToSelector(Selector("tableView:moveRowAtIndexPath"))) {
			datasource.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
		} else {
			return
		}
	}

	public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		datasource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
	}

	@objc
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let numOfSectionsFunc = datasource.numberOfSectionsInTableView {
//			var temp = numOfSectionsFunc(tableView)
			return numOfSectionsFunc(tableView)
		} else {
			return 0
		}
	}

}
