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

        // Hijack the delegate and datasource and make it use our wrapper.
        if tableView.delegate != nil {
            self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
            tableView.delegate = self.delegate
        }
        tableView.dataSource = self

        // Check the kind of cell to use
        switch adUnitType {
        case .dynamic:
            if tableView.dequeueReusableCell(withIdentifier: "DynamicAdUnitTableViewCell") == nil {
                let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                tableView.register(UINib(nibName: "DynamicAdUnitTableViewCell", bundle: bundle), forCellReuseIdentifier: "DynamicAdUnitTableViewCell")
            }
            break
        case .custom:
            if tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil {
                let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                tableView.register(UINib(nibName: "NativeAdView", bundle: bundle), forCellReuseIdentifier: "NativeAdTableViewCell")
            }
            break
            //            case .Big:
            //                if (tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") == nil) {
            //                    let bundle = PocketMediaNativeAdsBundle.loadBundle()!
            //                    tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: bundle), forCellReuseIdentifier: "BigNativeAdTableViewCell")
            //                }
            //            break
        case .standard:
            fallthrough
        default:
            if tableView.dequeueReusableCell(withIdentifier: "StandardAdUnitTableViewCell") == nil {
                let bundle = PocketMediaNativeAdsBundle.loadBundle()!
                tableView.register(UINib(nibName: "StandardAdUnitTableViewCell", bundle: bundle), forCellReuseIdentifier: "StandardAdUnitTableViewCell")
            }
            break
        }
    }

    open func getAdCell(_ nativeAd: NativeAd) -> AbstractAdUnitTableViewCell {
        var cell: AbstractAdUnitTableViewCell?
        switch adUnitType {
        case .dynamic:
            cell = tableView.dequeueReusableCell(withIdentifier: "DynamicAdUnitTableViewCell") as? AbstractAdUnitTableViewCell
            break
        case .custom:
            cell = tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") as? AbstractAdUnitTableViewCell
            break
            //            case .Big:
            //                cell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as? AbstractAdUnitTableViewCell
            //                break
        case .standard:
            fallthrough
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "StandardAdUnitTableViewCell") as? AbstractAdUnitTableViewCell
        }
        cell?.render(nativeAd)
        return cell!
    }

    // Data Source
    @objc
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listing = getNativeAdListing(indexPath) {
            return getAdCell(listing.ad)
        }
        return datasource.tableView(tableView, cellForRowAt: getOriginalPositionForElement(indexPath))
    }

    @objc
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adListingsPerSection[section]?.count {
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
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:))) {
            return datasource.tableView!(tableView, canEditRowAt: indexPath)
        }
        return true
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))) {
            return datasource.tableView!(tableView, canMoveRowAt: indexPath)
        }
        return true
    }

    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))) {
            return datasource.tableView!(tableView, sectionForSectionIndexTitle: title, at: index)
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))) {
            datasource.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        datasource.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }

    open override func onAdRequestSuccess(_ ads: [NativeAd]) {
        Logger.debugf("Received %d ads", ads.count)
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
        var adsInserted = 1

        for ad in ads {
            var numOfRowsInCurrentSection = datasource.tableView(tableView, numberOfRowsInSection: section)
            let limit = numOfRowsInCurrentSection + adsInserted
            var position: Int
            // try and get an ad position
            do {
                position = try Int(adPosition.getAdPosition(numOfRowsInCurrentSection))
            } catch let err as NSError {
                Logger.error(err)
                continue
            }
            // If we're out of positions move up a section.
            if position >= limit {
                adPosition.reset()
                section += 1
                adsInserted = 1

                numOfRowsInCurrentSection = datasource.tableView(tableView, numberOfRowsInSection: section)
                // Get a new position
                do {
                    position = try Int(adPosition.getAdPosition(numOfRowsInCurrentSection))
                } catch let err as NSError {
                    Logger.error(err)
                    continue
                }
            }
            // If that new section doesn't exist. Stop adding ads.
            if section >= maxSections {
                break
            }
            if adListingsPerSection[section] == nil {
                adListingsPerSection[section] = [:]
            }

            // Add the ad
            adListingsPerSection[section]![position] = NativeAdListing(ad: ad, position: position, numOfAdsBefore: adsInserted)
            adsInserted += 1
        }

        Logger.debugf("Set %d section ad listings", adListingsPerSection.count)
    }

    fileprivate func clear() {
        adListingsPerSection.removeAll()
        Logger.debug("Cleared adListings.")
    }

    // Called everytime tableView.reloadData is called.
    // Like 'notifyDataSetChanged' in android
    open func reload() {
        setAdPositions(self.ads)
    }

    // The actual important to a UITableView functions are down below here.
    @objc
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let numOfSectionsFunc = datasource.numberOfSections(`in`:) {
            return numOfSectionsFunc(tableView)
        }
        return 1
    }

    open func getOriginalPositionForElement(_ indexRow: IndexPath) -> IndexPath {
        if let listing = getNativeAdListingHigherThan(indexRow) {
            let normalizedIndexRow = listing.getOriginalPosition(indexRow)
            let maxRows = datasource.tableView(tableView, numberOfRowsInSection: normalizedIndexRow.section)

            // Because we really never want to be responsible for a crash :-(
            // We'll just do a quick fail safe. So we can all sleep at night: the normalizedIndexRow.row may not be higher than the the amount of rows we have for this section.
            if normalizedIndexRow.row >= maxRows || normalizedIndexRow.row < 0 {
                print("[INDEX] Normalized row is invalid @ \(normalizedIndexRow.row)")
                // We'll return 0. That one is probably available. Stops this unexpected behaviour from crashing the host app
                return IndexPath(row: 0, section: indexRow.section)
            }
            return normalizedIndexRow
        }
        return indexRow
    }
}
