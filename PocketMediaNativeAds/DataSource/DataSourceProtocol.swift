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

    /**
     Register a xib
    */
    func registerCell(_ identifier: String)

    /**
     Check if a xib is registered.
    */
    func checkCell(_ identifier: String) -> Bool
    
    /**
     Return the number of sections. If you're implementing a datasource that doesn't support sections, just return 1.
     - Important:
     Call the original data source to get the count. Do NOT sum the original amount + ads
     */
    func numberOfSections() -> Int
    
    /**
     Return the number of rows in a particular section. If you're implementing a datasource that doesn't support sections, just ignore the section parameter.
     - Important:
        Call the original data source to get the count. Do NOT sum the original amount + ads
    */
    func numberOfRowsInSection(section: Int) -> Int
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
