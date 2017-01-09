//
//  DataSourceProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 02/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import Foundation

/**
 A protocol that eacha datasource will need to conform to in order to be notified of new ads.
 */
@objc
public protocol DataSourceProtocol {
    /**
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     Abstract classes that a datasource should override. It's specific to the type of data source.
     */
    func onAdRequestSuccess(_ newAds: [NativeAd])
    /**
     Finds an ad listing which is lower than the index path of the given one.
     So in other words it finds the last ad listing before this indexRow.
     - returns:
     A native ad listing. With a lower index path than the one given.
     */
    func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing?

    func registerCell(_ identifier: String)

    func checkCell(_ identifier: String) -> Bool
}

/**
 Protocol extends the DataSourceProtocol protocol. In a tableViewDataSource we're talking rows!
 */
public protocol NativeAdTableViewDataSourceProtocol: DataSourceProtocol {
    /**
     Returns the amount of rows in a given section.
     */
    func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int
}
