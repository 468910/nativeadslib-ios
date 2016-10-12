//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

open class NativeAdTableViewDataSource: DataSource, UITableViewDataSource {
    open var datasource: UITableViewDataSource
    open var tableView: UITableView
    open var delegate: NativeAdTableViewDelegate?
    open var controller: UIViewController!
    fileprivate var adPosition: AdPosition

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
		case .custom:
			if (tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.register(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
			}
			break
//		case .Big:
//			if (tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") == nil) {
//				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
//				tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
//			}
//			break
		default:
			if (tableView.dequeueReusableCell(withIdentifier: "NativeAdTableViewCell") == nil) {
				let bundle = PocketMediaNativeAdsBundle.loadBundle()!
				tableView.register(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
			}
			break
		}
	}

	open func getAdCell(_ nativeAd: NativeAd) -> NativeAdCell {
		switch (adUnitType) {
            case .custom:
              let cell = tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") as! NativeAdCell
                //cell.configureAdView(nativeAd)
                return cell
        //		case .Big:
        //			let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
        //			cell.configureAdView(nativeAd)
        //			return cell;
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NativeAdTableViewCell") as! NativeAdCell
                cell.configureAdView(nativeAd)
                return cell
        }
	}

	// Data Source
	@objc
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    	if let nativeAd = getNativeAdListing(indexPath) {
			return getAdCell(nativeAd)
		}
        return datasource.tableView(tableView, cellForRowAt: IndexPath(row: normalize(indexPath), section: (indexPath as NSIndexPath).section))
	}
    
	@objc
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adListings[section]?.count {
            return datasource.tableView(tableView, numberOfRowsInSection: section) + ads
        }
        
        return datasource.tableView(tableView, numberOfRowsInSection: section)
	}

	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForHeaderInSection: section) {
			return string
		}
        return nil
	}

	open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if let string = datasource.tableView?(tableView, titleForFooterInSection: section) {
			return string
		}
        return nil
	}

	open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      if (datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)))){
			return datasource.tableView!(tableView, canEditRowAt: indexPath)
		}
        return true
	}

	open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      if (datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)))) {
			return datasource.tableView!(tableView, canMoveRowAt: indexPath)
		}
		return true
	}

	open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
      if (datasource.responds(to: #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)))) {
			return datasource.tableView!(tableView, sectionForSectionIndexTitle: title, at: index)
		}
        return 0
	}

	open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
      if (datasource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))) {
			datasource.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
		}
	}

	open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		datasource.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
	}
    
    open override func onAdRequestSuccess(_ ads: [NativeAd]) {
        Logger.debugf("Received %d ads", ads.count);
        self.ads = ads
        setAdPositions(ads)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    open func setAdPositions(_ ads: [NativeAd]) {
        adPosition.reset()
        clear()
        let maxSections = datasource.numberOfSections!(in: tableView)
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
    
    fileprivate func clear() {
        adListings.removeAll()
        Logger.debug("Cleared adListings.");
    }
    
    //Called everytime tableView.reloadData is called.
    //Like 'notifyDataSetChanged' in android
    open func reload() {
        setAdPositions(self.ads)
    }

    //The actual important to a UITableView functions are down below here.
	@objc
	open func numberOfSections(in tableView: UITableView) -> Int {
		if let numOfSectionsFunc = datasource.numberOfSections(`in`:) {
			return numOfSectionsFunc(tableView)
		}
        return 1
	}

    func normalize(_ indexRow: IndexPath) -> Int {
        var numOfAdsInsertedInSection = 0
        if let ads = adListings[(indexRow as NSIndexPath).section]?.sorted(by: { $0.0 < $1.0 }) {
            for ad in ads {
                if((indexRow as NSIndexPath).row >= ad.1.position) {
                    numOfAdsInsertedInSection += 1
                } else {
                    break;
                }
            }
        }
        return (indexRow as NSIndexPath).row - numOfAdsInsertedInSection
    }
    
}
