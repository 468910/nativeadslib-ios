//
//  UITableViewDataSourceAdapater.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit
/**
 Wraps around a datasource so it contains both a mix of ads and none ads.
 */
open class NativeAdTableViewDataSource: DataSource, UITableViewDataSource {
    /// Original datasource.
    open var datasource: UITableViewDataSource
    /// Original tableView.
    open var tableView: UITableView
    /// Original deglegate.
    open var delegate: NativeAdTableViewDelegate?
    // Ad position logic.
    fileprivate var adPosition: AdPosition

    /**
     Reset the datasource. if this wrapper is deinitialized.
     */
    deinit {
        self.tableView.dataSource = datasource
    }

    /**
     Hijacks the sent delegate and datasource and make it use our wrapper. Also registers the ad unit we'll be using.
     - parameter controller: The controller to create NativeAdTableViewDelegate
     - parameter tableView: The tableView this datasource is attached to.
     - parameter adPosition: The instance that will define where ads are positioned.
     */
    @objc
    public required init(controller: UIViewController, tableView: UITableView, adPosition: AdPosition) {
        if tableView.dataSource != nil {
            self.datasource = tableView.dataSource!
        } else {
            preconditionFailure("Your tableview must have a dataSource set before use.")
        }

        self.adPosition = adPosition
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

        if adUnitType == .custom {
            if tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil {
                preconditionFailure("Something went wrong here. CustomAdCell should've already been registered at the NativeAdStream class or when doing a custom integration by the host app.")
            }
        } else {
            // Register the ad unit we'll be using.
            registerAdUnit(name: adUnitType.nibName)
        }
    }

    /**
     This function checks if we have a cell registered with that name. If not we'll register it.
     */
    private func registerAdUnit(name: String) {
        if tableView.dequeueReusableCell(withIdentifier: name) == nil {
            let bundle = PocketMediaNativeAdsBundle.loadBundle()!
            tableView.register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
        }
    }

    /**
     Gets the view cell for this ad.
     - Returns:
     View cell of this ad.
     - Important:
     If we can't find the adUnitType.nibname and it isn't of the instance AbstractAdUnitTableViewCell we'll return a AbstractAdUnitTableViewCell so it doesn't crash.
     */
    open func getAdCell(_ nativeAd: NativeAd) -> AbstractAdUnitTableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: adUnitType.nibName) as? AbstractAdUnitTableViewCell {
            // Render it.
            cell.render(nativeAd)
            return cell
        }
        Logger.error("Ad unit wasn't registered? Or it changed halfway?")
        return AbstractAdUnitTableViewCell()
    }

    /**
     Required. Asks the data source for a cell to insert in a particular location of the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listing = getNativeAdListing(indexPath) {
            return getAdCell(listing.ad)
        }
        return datasource.tableView(tableView, cellForRowAt: getOriginalPositionForElement(indexPath))
    }

    /**
     Returns the number of rows (table cells) in a specified section.
     */
    @objc
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ads = adListingsPerSection[section]?.count {
            return datasource.tableView(tableView, numberOfRowsInSection: section) + ads
        }
        return datasource.tableView(tableView, numberOfRowsInSection: section)
    }

    /**
     Asks the data source for the title of the header of the specified section of the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let string = datasource.tableView?(tableView, titleForHeaderInSection: section) {
            return string
        }
        return nil
    }

    /**
     Asks the data source for the title of the footer of the specified section of the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let string = datasource.tableView?(tableView, titleForFooterInSection: section) {
            return string
        }
        return nil
    }

    /**
     Asks the data source to verify that the given row is editable.
     */
    @objc
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:))) {
            return datasource.tableView!(tableView, canEditRowAt: indexPath)
        }
        return true
    }

    /**
     Asks the data source whether a given row can be moved to another location in the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))) {
            return datasource.tableView!(tableView, canMoveRowAt: indexPath)
        }
        return true
    }

    /**
     Asks the data source to return the index of the section having the given title and section title index.
     */
    @objc
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))) {
            return datasource.tableView!(tableView, sectionForSectionIndexTitle: title, at: index)
        }
        return 0
    }

    /**
     Tells the data source to move a row at a specific location in the table view to another location.
     */
    @objc
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if datasource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))) {
            datasource.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
    }

    /**
     default is UITableViewCellEditingStyleNone. This is set by UITableView using the delegate's value for cells who customize their appearance
     */
    @objc
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        datasource.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }

    /**
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     Abstract classes that a datasource should override. It's specific to the type of data source.
     */
    open override func onAdRequestSuccess(_ ads: [NativeAd]) {
        Logger.debugf("Received %d ads", ads.count)
        self.ads = ads
        setAdPositions(ads)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    /**
     This method is responsible for going through a list of new ads and populating self.adListingsPerSection.
     - parameter ads: Array of ads that should be add.
     */
    open func setAdPositions(_ ads: [NativeAd]) {
        adPosition.reset()
        clear()
        var maxSections = 1

        if let _ = datasource.numberOfSections?(in: tableView) {
            maxSections =
                datasource.numberOfSections!(in: tableView)
        }
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

    /**
     Call if you want to clear all the ads from the datasource.
     */
    fileprivate func clear() {
        adListingsPerSection.removeAll()
        Logger.debug("Cleared adListings.")
    }

    /**
     Called everytime tableView.reloadData is called.
     Just like 'notifyDataSetChanged' in android
     */
    open func reload() {
        setAdPositions(self.ads)
    }

    /**
     The actual important to a UITableView functions are down below here.
     */
    @objc
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let numOfSectionsFunc = datasource.numberOfSections(in:) {
            return numOfSectionsFunc(tableView)
        }
        return 1
    }

    /**
     Get the original position of a element on that indexRow. If we have an ad listed before this position normalize.
     - Returns:
     A normalized indexPath.
     */
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
