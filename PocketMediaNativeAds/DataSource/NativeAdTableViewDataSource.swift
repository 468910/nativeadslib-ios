//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class NativeAdTableViewDataSource: DataSource, UITableViewDataSource {
    public var datasource: UITableViewDataSource
    public var tableView: UITableView
    public var delegate: NativeAdTableViewDelegate?
    public var controller: UIViewController!
    private var adPosition: AdPosition

	deinit {
		self.tableView.dataSource = datasource
	}

	@objc
    public required init(controller: UIViewController, tableView: UITableView, adPosition: AdPosition) {
        if tableView.dataSource != nil {
            self.datasource = tableView.dataSource!
        } else {
            preconditionFailure("Your tableview must have a dataSource set before use.")
        }
        
        self.adPosition = adPosition
        self.controller = controller
        self.adPosition = adPosition
		self.tableView = tableView
		super.init()
        UITableView.swizzleNativeAds(tableView)

        //Hijack the delegate and datasource and make it use our wrapper.
        if tableView.delegate != nil {
            self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
            tableView.delegate = self.delegate
        }
		tableView.dataSource = self

		// Check the kind of cell to use
		switch (adUnitType) {
            case .Dynamic:
                if (tableView.dequeueReusableCellWithIdentifier("DynamicNativeAdTableViewCell") == nil) {
                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                    tableView.registerNib(UINib(nibName: "DynamicNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "DynamicNativeAdTableViewCell")
                }
                break
            case .Standard:
                fallthrough
            default:
                if (tableView.dequeueReusableCellWithIdentifier("StandardAdUnitTableViewCell") == nil) {
                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                    tableView.registerNib(UINib(nibName: "StandardAdUnitTableViewCell", bundle: bundle), forCellReuseIdentifier: "StandardAdUnitTableViewCell")
                }
                break
		}
	}

	public func getAdCell(nativeAd: NativeAd) -> AbstractAdUnitTableViewCell {
        var cell: AbstractAdUnitTableViewCell?
		switch (adUnitType) {
//            case .Dynamic:
//                let cell = tableView.dequeueReusableCellWithIdentifier("DynamicNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
//                break
            case .Standard:
                fallthrough
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("StandardAdUnitTableViewCell") as! AbstractAdUnitTableViewCell
        }
        cell?.render(nativeAd)
        return cell!
    }

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	if let nativeAd = getNativeAdListing(indexPath) {
			return getAdCell(nativeAd)
		}
        return datasource.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: normalize(indexPath), inSection: indexPath.section))
	}
    
	@objc
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adListings[section]?.count {
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
    
    public override func onAdRequestSuccess(ads: [NativeAd]) {
        Logger.debugf("Received %d ads", ads.count);
        self.ads = ads
        setAdPositions(ads)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    public func setAdPositions(ads: [NativeAd]) {
        adPosition.reset()
        clear()
        let maxSections = datasource.numberOfSectionsInTableView!(tableView)
        var section = 0
        for ad in ads {
            let numOfRowsInCurrentSection = datasource.tableView(tableView, numberOfRowsInSection: section)
            var position: Int
            do {
                position = try Int(adPosition.getAdPosition(numOfRowsInCurrentSection))
            } catch let err as NSError {
                Logger.error(err)
                continue
            }
            //If we're out of positions move up a section.
            if position > numOfRowsInCurrentSection {
                adPosition.reset()
                section += 1
            }
            //If that new section doesn't exist. Stop adding ads.
            if section > maxSections {
                break
            }
            if adListings[section] == nil {
                adListings[section] = [:]
            }
            
            //Add the ad
            adListings[section]![position] = NativeAdInfo(ad: ad, position: position)
        }
        Logger.debugf("Set %d ad listings", adListings.count)
    }
    
    private func clear() {
        adListings.removeAll()
        Logger.debug("Cleared adListings.");
    }
    
    //Called everytime tableView.reloadData is called.
    //Like 'notifyDataSetChanged' in android
    public func reload() {
        setAdPositions(self.ads)
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
        if let ads = adListings[indexRow.section]?.sort({ $0.0 < $1.0 }) {
            for ad in ads {
                if(indexRow.row >= ad.1.position) {
                    numOfAdsInsertedInSection += 1
                } else {
                    break;
                }
            }
        }
        return indexRow.row - numOfAdsInsertedInSection
    }
    
}
