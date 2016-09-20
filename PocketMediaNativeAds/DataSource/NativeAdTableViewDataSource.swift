//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

public class NativeAdTableViewDataSource: DataSource, UITableViewDataSource, NativeAdTableViewDataSourceProtocol {
    public var datasource: UITableViewDataSource
    public var tableView: UITableView
    public var delegate: NativeAdTableViewDelegate?
    public var controller: UIViewController!

	deinit {
		self.tableView.dataSource = datasource
	}

	@objc
    public required init(controller: UIViewController, tableView: UITableView) {
        self.controller = controller
        if tableView.dataSource != nil {
            self.datasource = tableView.dataSource!
        } else {
            preconditionFailure("Your tableview must have a dataSource set before use.")
        }
		self.tableView = tableView
		super.init()
        
        //Hijack the delegate and datasource and make it use our wrapper.
        if tableView.delegate != nil {
            self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
            tableView.delegate = self.delegate
        }
		tableView.dataSource = self

		// Check the kind of cell to use
		switch (adUnitType) {
		case .Custom:
			if (tableView.dequeueReusableCellWithIdentifier("CustomAdCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
			}
			break
//		case .Big:
//			if (tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") == nil) {
//				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
//				tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
//			}
//			break
		default:
			if (tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
			}
			break
		}
	}

	public func getAdCellForTableView(nativeAd: NativeAd) -> UITableViewCell {
		switch (adUnitType) {
		case .Custom:
			let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("CustomAdCell") as! NativeAdCell
			cell.configureAdView(nativeAd)
			return cell
//		case .Big:
//			let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
//			cell.configureAdView(nativeAd)
//			return cell;
		default:
			let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
			cell.configureAdView(nativeAd)
			return cell
		}
	}

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	if let val = isAdAtposition(indexPath) {
			return getAdCellForTableView(val)
		}
			return datasource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: normalize(indexPath), inSection: indexPath.section))
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

		return getCountForSection(datasource.tableView(tableView, numberOfRowsInSection: section), totalRowsInSection: totalRows)
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

    public override func onUpdateDataSource() {
        tableView.reloadData()
    }

    //The actual important to a UITableView functions are down below here.
	@objc
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let numOfSectionsFunc = datasource.numberOfSectionsInTableView {
			return numOfSectionsFunc(tableView)
		} else {
			return 0
		}
	}

    public override func numberOfElements() -> Int {
        var numOfRows = 0
        for i in 0...max(0, datasource.numberOfSectionsInTableView!(tableView) - 1) {
            numOfRows += datasource.tableView(tableView, numberOfRowsInSection: i)
        }
        return numOfRows
    }

    public override func getTruePosistionInDataSource(indexPath: NSIndexPath) -> Int {
        return IndexRowNormalizer.getTruePosistionForIndexPath(indexPath, datasource: self)
    }

    func normalize(indexRow: NSIndexPath) -> Int {
        let pos = IndexRowNormalizer.getTruePosistionForIndexPath(indexRow, datasource: self as! NativeAdTableViewDataSourceProtocol)
        return IndexRowNormalizer.normalize(pos, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: ads.count)
    }
}
