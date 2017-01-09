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
     Hijacks the sent delegate and datasource and make it use our wrapper. Also registers the ad unit we'll be using.
     - parameter controller: The controller to create NativeAdTableViewDelegate
     - parameter tableView: The tableView this datasource is attached to.
     - parameter adPosition: The instance that will define where ads are positioned.
     */
    @objc
    public required init(controller: UIViewController, tableView: UITableView, adPosition: AdPosition) {
        if tableView.dataSource == nil {
            preconditionFailure("Your tableview must have a dataSource set before use.")
        }
        self.datasource = tableView.dataSource!
        self.adPosition = adPosition
        self.tableView = tableView
        super.init(adUnitType: AdUnitType.tableViewRegular, adPosition: adPosition)
        UITableView.swizzleNativeAds(tableView)

        // Hijack the delegate and datasource and make it use our wrapper.
        if tableView.delegate != nil {
            self.delegate = NativeAdTableViewDelegate(datasource: self, controller: controller, delegate: tableView.delegate!)
            tableView.delegate = self.delegate
        }
        tableView.dataSource = self
    }
    
    /**
     Reset the datasource. if this wrapper is deinitialized.
     */
    deinit {
        self.tableView.dataSource = datasource
    }

    /**
     This function checks if we have a cell registered with that name. If not we'll register it.
     */
    public override func registerCell(_ identifier: String) {
        if checkCell(identifier) {
            return
        }
        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        tableView.register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
    }

    public override func checkCell(_ identifier: String) -> Bool {
        return tableView.dequeueReusableCell(withIdentifier: AdUnitType.customXib.nibName) != nil
    }

    /**
     Gets the view cell for this ad.
     - Returns:
     View cell of this ad.
     - Important:
     If we can't find the adUnitType.nibname and it isn't of the instance NativeAdTableViewCell we'll return a UITableViewCell so it doesn't crash.
     */
    open func getAdCell(_ nativeAd: NativeAd) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: adUnitType.nibName) as? NativeAdTableViewCell {
            // Render it.
            cell.render(nativeAd)
            return cell
        }
        Logger.error("Ad unit wasn't registered? Or it changed halfway?")
        return UITableViewCell()
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
        super.onAdRequestSuccess(ads)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    /**
     The actual important to a UITableView functions are down below here.
     */
    @objc
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let result = datasource.numberOfSections?(in: tableView) {
            return result
        }
        return 1
    }
    
    public override func numberOfSections() -> Int {
        return numberOfSections(in: self.tableView)
    }
    
    public override func numberOfRowsInSection(section: Int) -> Int {
        return datasource.tableView(tableView, numberOfRowsInSection: section)
    }
    
}
