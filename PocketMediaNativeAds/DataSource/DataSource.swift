//
//  DataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 19/09/16.
//  This class is a abstract class that contains all important stuff that the datasources will have alike.
//

import Foundation

/// Ad listings per position
public typealias AdListingsAndPositions = [Int: NativeAdListing]
/// Adlistings and their position per section.
public typealias AdsForSectionMap = [Int: AdListingsAndPositions]

/**
 Abstract class that defines the bare datasource functionality.
 */
@objc
open class DataSource: NSObject, DataSourceProtocol {

    /// Adlistings and their position per section.
    open var adListingsPerSection: AdsForSectionMap = AdsForSectionMap()

    /// Ads shown in this data source.
    open var ads: [NativeAd] = [NativeAd]()

    /**
     The AdUnitType defines what kind of ad is shown.
     */
    open var adUnitType: AdUnitType = .standard

    /**
     Finds an ad listing for a given index path.
     - returns:
     a native ad listing. based on the index path.
     - important:
     If we don't have a ad listing on that index Path. This method will return nil.s
     */
    open func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing? {
        if let val = adListingsPerSection[indexPath.section]?[indexPath.row] {
            return val
        }
        return nil
    }

    /**
     Finds an ad listing which is lower than the index path of the given one.
     So in other words it finds the last ad listing before this indexRow.
     - returns:
     A native ad listing. With a lower index path than the one given.
     */
    open func getNativeAdListingHigherThan(_ indexRow: IndexPath) -> NativeAdListing? {
        var result: NativeAdListing?
        let position = indexRow.row

        if let listings = adListingsPerSection[indexRow.section] {
            for (_, listing) in listings.sorted(by: { $0.0 < $1.0 }) {
                // if the iterated position is lower than the position we are looking for save it.
                // So in the end we have the highest listing position for the position we are looking for. Aka the closest previous ad listing
                if listing.position < position {
                    result = listing
                }
                // If the listing we are iterating through is higher than the position. Than we can stop. Because we're looking for previous ad listings. Not ones that are ahead of us.
                if position <= listing.position {
                    break
                }
            }
        }
        return result
    }

    /**
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     Abstract classes that a datasource should override. It's specific to the type of data source.
     */
    open func onAdRequestSuccess(_ newAds: [NativeAd]) {
        preconditionFailure("This method must be overridden")
    }
}
