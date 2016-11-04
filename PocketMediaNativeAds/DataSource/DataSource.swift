//
//  DataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 19/09/16.
//  This class is a abstract class that contains all important stuff that the datasources will have alike.
//

import Foundation

/*
 * Wraps around the native ad. It represents an ad displayed in a collection.
 * Contains all the logic of the position of the original host array.
 * The idea is that we find the last adListing in the shown list, and based on that figure out what the original position was of a non ad view.
 * @author Pocket Media
 */
@objc
public class NativeAdListing: NSObject {

    /**
     * The ad that is added.
     */
    public var ad: NativeAd

    /**
     *  Position of where the add is added
     */
    public var position: Int

    /**
     *  The amount of adListings that have been added.
     */
    public var numOfAdsBefore: Int

    init(ad: NativeAd, position: Int, numOfAdsBefore: Int) {
        self.ad = ad
        self.position = position
        self.numOfAdsBefore = numOfAdsBefore
    }

    func getOriginalPosition(indexPath: NSIndexPath) -> NSIndexPath {
        let position = indexPath.row
        let normalizedPosition = position - self.numOfAdsBefore
        return NSIndexPath(forRow: normalizedPosition, inSection: indexPath.section)
    }
}

public typealias AdListingsAndPositions = [Int: NativeAdListing]
public typealias AdsForSectionMap = [Int: AdListingsAndPositions]

@objc
public class DataSource: NSObject, DataSourceProtocol {

    public var adListingsPerSection: AdsForSectionMap = AdsForSectionMap()

    public var ads: [NativeAd] = [NativeAd]()

    // The AdUnitType defines what kind of ad is shown.
    public var adUnitType: AdUnitType = .Standard

    public func getNativeAdListing(indexPath: NSIndexPath) -> NativeAdListing? {
        if let val = adListingsPerSection[indexPath.section]?[indexPath.row] {
            return val
        }
        return nil
    }

    public func getNativeAdListingHigherThan(indexRow: NSIndexPath) -> NativeAdListing? {
        var result: NativeAdListing?
        let position = indexRow.row

        if let listings = adListingsPerSection[indexRow.section] {
            for (_, listing) in listings.sort({ $0.0 < $1.0 }) {
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

    // Abstract classes that a datasource should override
    public func onAdRequestSuccess(newAds: [NativeAd]) {
        preconditionFailure("This method must be overridden")
    }

    public func getTruePositionInDataSource(indexPath: NSIndexPath) -> Int {
        preconditionFailure("This method must be overridden")
    }

    public func numberOfElements() -> Int {
        preconditionFailure("This method must be overridden")
    }
}
