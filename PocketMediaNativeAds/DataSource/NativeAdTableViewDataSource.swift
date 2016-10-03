//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Foundation


public struct NativeAdInfo {
    var ad : NativeAd
    var position : Int
}

public typealias AdsForSectionMap = [Int : [Int : NativeAdInfo]]

public class NativeAdTableViewDataSource: DataSource, UITableViewDataSource {
    public var datasource: UITableViewDataSource
    public var tableView: UITableView
    public var delegate: NativeAdTableViewDelegate?
    public var controller: UIViewController!
    
    public var adsForSection : AdsForSectionMap = AdsForSectionMap()

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
          let cell = tableView.dequeueReusableCellWithIdentifier("CustomAdCell") as! NativeAdCell
			//cell.configureAdView(nativeAd)
			return cell
//		case .Big:
//			let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
//			cell.configureAdView(nativeAd)
//			return cell;
		default:
            let cell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
			cell.configureAdView(nativeAd)
			return cell		}
	}

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	if let val = isAdAtposition(indexPath) {
			var cell = getAdCellForTableView(val) as! NativeAdCell
//            cell.adTitle?.text = String(indexPath.row.description)
            return cell
		}
			return datasource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: normalize(indexPath), inSection: indexPath.section))
	}
    
	@objc
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adsForSection[section]?.count {
            return datasource.tableView(tableView, numberOfRowsInSection: section) + ads
        }
        
        return datasource.tableView(tableView, numberOfRowsInSection: section)
	}

	public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForHeaderInSection: section) {
			return string
		}
        return nil
	}

	public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForFooterInSection: section) {
			return string
		}
        return nil
	}

	public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      if (datasource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:canEditRowAtIndexPath:)))){
			return datasource.tableView!(tableView, canEditRowAtIndexPath: indexPath)
		}
        return true
	}

	public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      if (datasource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:canMoveRowAtIndexPath:)))) {
			return datasource.tableView!(tableView, canMoveRowAtIndexPath: indexPath)
		}
		return true
	}

	public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
      if (datasource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:atIndex:)))) {
			return datasource.tableView!(tableView, sectionForSectionIndexTitle: title, atIndex: index)
		}
        return 0
	}

	public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
      if (datasource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:moveRowAtIndexPath:toIndexPath:)))) {
			datasource.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
		}
	}

	public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		datasource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
	}

    public override func onUpdateDataSource(newAds: [NativeAd]) {
        adsForSection.removeAll()
        
        let numOfSections = datasource.numberOfSectionsInTableView!(tableView)
        var totalNumOfElements = 0
        var ads = newAds
        
        
        for i in 0..<numOfSections {
            let numOfRowsInCurrentSection = datasource.tableView(tableView, numberOfRowsInSection: i)
            
            if(ads.count <= 0 || firstAdPosition > numOfRowsInCurrentSection){
                break;
            }
        
            adsForSection[i] = [:]
            var adsInsertedCurrentSection = 0
            var adsLeft = true
            
            
            if(numOfRowsInCurrentSection > firstAdPosition){
                adsForSection[i]![firstAdPosition] = NativeAdInfo(ad: ads.removeFirst(), position: firstAdPosition)
                adsInsertedCurrentSection += 1
            }
            
            while(adsLeft){
                if(numOfRowsInCurrentSection + adsInsertedCurrentSection >= firstAdPosition + adMargin * adsInsertedCurrentSection){
                    adsForSection[i]![firstAdPosition + adMargin * adsInsertedCurrentSection] = NativeAdInfo(ad: ads.removeFirst(),
                                    position: firstAdPosition + adMargin * adsInsertedCurrentSection)
                    adsInsertedCurrentSection += 1
                }else {
                    adsLeft = false
                }
            }
        }
        tableView.reloadData()
    }

    //The actual important to a UITableView functions are down below here.
	@objc
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let numOfSectionsFunc = datasource.numberOfSectionsInTableView {
			return numOfSectionsFunc(tableView)
		}
        return 1
	}


    func normalize(indexRow: NSIndexPath) -> Int {
        var numOfAdsInsertedInSection = 0
    
        if let ads = adsForSection[indexRow.section]?.sort({ $0.0 < $1.0 }) {
            for ad in ads {
                if(indexRow.row >= ad.1.position){
                numOfAdsInsertedInSection += 1
                }else {
                    break;
                }
            }
        }
    
        return indexRow.row - numOfAdsInsertedInSection
    }
    
    public override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        if let val = adsForSection[indexPath.section]?[indexPath.row]?.ad {
            return val
        }
        return nil
    }
    
    func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int) -> Int {
        return 1
    }
    
}
