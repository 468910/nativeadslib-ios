//
//  NativeAdListing.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 02/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 * Wraps around the native ad. It represents an ad displayed in a collection.
 * Contains all the logic of the position of the original host array.
 * The idea is that we find the last adListing in the shown list, and based on that figure out what the original position was of a non ad view.
 * @author Pocket Media
 */
@objc
open class NativeAdListing: NSObject {

    /**
     * The ad that is added.
     */
    open var ad: NativeAd

    /**
     *  Position of where the add is added
     */
    open var position: Int

    /**
     *  The amount of adListings that have been added.
     */
    open var numOfAdsBefore: Int

    /**
     Initializes NativeAdListing which will wrap around a nativeAd.
     - parameter ad: The ad in question.
     - parameter position: The position the ad will be in. (Not normalized)
     - parameter numOfAdsBefore: The amount of ads before this ad.
     */
    init(ad: NativeAd, position: Int, numOfAdsBefore: Int) {
        self.ad = ad
        self.position = position
        self.numOfAdsBefore = numOfAdsBefore
    }

    /**
     Calculates a normalized position of this ad based on the indexPath of the last ad before this one.
     - parameter indexPath: The index path of the last ad before this ad.
     - returns:
     a normalized position of the ad.
     */
    func getOriginalPosition(_ indexPath: IndexPath) -> IndexPath {
        let position = indexPath.row
        let normalizedPosition = position - self.numOfAdsBefore

        return IndexPath(row: normalizedPosition, section: indexPath.section)
    }
}
