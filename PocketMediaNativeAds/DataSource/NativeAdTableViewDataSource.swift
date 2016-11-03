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
                if (tableView.dequeueReusableCellWithIdentifier("DynamicAdUnitTableViewCell") == nil) {
                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                    tableView.registerNib(UINib(nibName: "DynamicAdUnitTableViewCell", bundle: bundle), forCellReuseIdentifier: "DynamicAdUnitTableViewCell")
                }
                break
            case .Custom:
                if (tableView.dequeueReusableCellWithIdentifier("CustomAdCell") == nil) {
                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                    tableView.registerNib(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
                }
                break
//            case .Big:
//                if (tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") == nil) {
//                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
//                    tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
//                }
//            break
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
            case .Dynamic:
                cell = tableView.dequeueReusableCellWithIdentifier("DynamicAdUnitTableViewCell") as? AbstractAdUnitTableViewCell
                break
            case .Custom:
                cell = tableView.dequeueReusableCellWithIdentifier("CustomAdCell") as? AbstractAdUnitTableViewCell
                break
//            case .Big:
//                cell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as? AbstractAdUnitTableViewCell
//                break
            case .Standard:
                fallthrough
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("StandardAdUnitTableViewCell") as? AbstractAdUnitTableViewCell
        }
        cell?.render(nativeAd)
        return cell!
    }

	// Data Source
	@objc
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    	if let listing = getNativeAdListing(indexPath) {
			return getAdCell(listing.ad)
		}
        
        let normalizedPosition = getOriginalPositionForElement(indexPath)
        
        return datasource.tableView(tableView, cellForRowAtIndexPath: normalizedPosition)
	}
    
	@objc
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adListingsPerSection[section]?.count {
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
        var adsInserted = 1
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
                adsInserted = 0
            }
            //If that new section doesn't exist. Stop adding ads.
            if section >= maxSections {
                break
            }
            if adListingsPerSection[section] == nil {
                adListingsPerSection[section] = [:]
            }
            
            //Add the ad
            adListingsPerSection[section]![position] = NativeAdListing(ad: ad, position: position, numOfAdsBefore: adsInserted)
            adsInserted += 1
        }
        
        /*
        for (section, adListings) in adListingsPerSection {
            //Sort
            adListingsPerSection[section] = adListingsPerSection[section]!.sort({ $0.0 < $1.0 }) as! [Int : NativeAdListing]
        }
         */
        
        Logger.debugf("Set %d section ad listings", adListingsPerSection.count)
    }
    
    private func clear() {
        adListingsPerSection.removeAll()
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

    func getOriginalPositionForElement(indexRow: NSIndexPath) -> NSIndexPath {
        let position = indexRow.row
        
        /*
        if position == 3 {
            print("death")
        }
        */
        
        if let listing = getNativeAdListingHigherThan(indexRow) {
            return listing.getOriginalPosition(indexRow)
        }
        return indexRow
    }
    
}
