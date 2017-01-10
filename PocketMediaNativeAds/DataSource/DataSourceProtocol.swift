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
     From: DataSourceProtocol
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     Abstract classes that a datasource should override. It's specific to the type of data source.
     */
    func onAdRequestSuccess(_ newAds: [NativeAd])
    /**
     From: DataSourceProtocol
     Finds an ad listing which is lower than the index path of the given one.
     So in other words it finds the last ad listing before this indexRow.
     - returns:
     A native ad listing. With a lower index path than the one given.
     */
    func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing?

    /**
     Registers a nib object containing a cell with the table view under a specified identifier.
    */
    func registerNib(nib: UINib?, identifier: String)
    
    /**
     From: DataSourceProtocol
     Return the cell of a identifier.
     - parameter: adType
     The type of ad which holds the reuse identifier for the specified cell. This parameter must not be nil.
     - parameter: indexPath
     The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.
     */
    func dequeueReusableCell(identifier: String, indexPath: IndexPath) -> UIView?
    
    /**
     From: DataSourceProtocol
     Return the number of sections. If you're implementing a datasource that doesn't support sections, just return 1.
     - Important:
     Call the original data source to get the count.
     */
    func numberOfSections() -> Int
    
    /**
     From: DataSourceProtocol
     Return the number of rows in a particular section. If you're implementing a datasource that doesn't support sections, just ignore the section parameter.
     - Important:
        Call the original data source to get the count. Do NOT sum the original amount + ads
    */
    func numberOfRowsInSection(section: Int) -> Int
}
