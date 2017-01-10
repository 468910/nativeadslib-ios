
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

    // Ad position logic.
    fileprivate var adPosition: AdPosition

    /// Ads shown in this data source.
    open var ads: [NativeAd] = [NativeAd]()

    private let customXib: UINib?

    /**
     The AdUnitType defines what kind of ad is shown.
     */
    open let adUnit: AdUnit!

    init(type: AdUnit.UIType, customXib: UINib?, adPosition: AdPosition) {
        var uiType = type
        if customXib != nil {
            uiType = AdUnit.UIType.CustomView
        }
        self.adUnit = AdUnit(type: uiType)
        self.adPosition = adPosition
        self.customXib = customXib
        super.init()
    }

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
     Gets the view cell for this ad.
     - Returns:
     View cell of this ad.
     - Important:
     If we can't find the adUnitType.nibname and it isn't of the instance NativeViewCell we'll return a UITableViewCell just be sure it doesn't crash.
     */
    open func getAdCell(_ nativeAd: NativeAd, indexPath: IndexPath) -> UIView {
        if let nativeAdCell = getCell(nativeAd: nativeAd, indexPath: indexPath) as? NativeViewCell {
            // Render it.
            nativeAdCell.render(nativeAd)
            if let cell = nativeAdCell as? UIView {
                return cell
            }
        }
        Logger.error("Ad unit wasn't registered? Or it changed halfway?")
        return UITableViewCell()
    }

    private func getCell(nativeAd: NativeAd, indexPath: IndexPath) -> UIView? {
        let identifier = adUnit.getNibIdentifier(ad: nativeAd)
        // No we can't check first if it hasn't already been registered. In a collectionView this seems to be absent, it will throw a terrible non catchable error instead of just returning nil if it hasn't been registered like in the tableView. Performance wise nothing seems to have changed registering it everytime.
        registerNib(nib: customXib, identifier: identifier)
        return dequeueReusableCell(identifier: identifier, indexPath: indexPath)
    }

    /**
     Method that dictates what happens when a ad network request resulted successful. It should kick off what to do with this list of ads.
     - important:
     This method should be called if overriden.
     */
    open func onAdRequestSuccess(_ newAds: [NativeAd]) {
        Logger.debugf("Received %d ads", ads.count)
        ads = newAds
        setAdPositions(ads)
    }

    /**
     This function checks if we have a cell registered with that name. If not we'll register it.
     */
    public func registerNib(nib: UINib?, identifier: String) {
        preconditionFailure("This method must be overridden")
    }

    public func dequeueReusableCell(identifier: String, indexPath: IndexPath? = nil) -> UIView? {
        preconditionFailure("This method must be overridden")
        return nil
    }

    public func numberOfSections() -> Int {
        preconditionFailure("This method must be overridden")
        return 1
    }

    public func numberOfRowsInSection(section: Int) -> Int {
        preconditionFailure("This method must be overridden")
        return 0
    }

    /**
     This method is responsible for going through a list of new ads and populating self.adListingsPerSection.
     - parameter ads: Array of ads that should be add.
     */
    open func setAdPositions(_ ads: [NativeAd]) {
        adPosition.reset()
        clear()
        var maxSections = numberOfSections()
        var section = 0
        var adsInserted = 1

        for ad in ads {
            var numOfRowsInCurrentSection = numberOfRowsInSection(section: section)
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

                numOfRowsInCurrentSection = numberOfRowsInSection(section: section)
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
    public func clear() {
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
     Get the original position of a element on that indexRow. If we have an ad listed before this position normalize.
     - Returns:
     A normalized indexPath.
     */
    open func getOriginalPositionForElement(_ indexRow: IndexPath) -> IndexPath {
        if let listing = getNativeAdListingHigherThan(indexRow) {
            let normalizedIndexRow = listing.getOriginalPosition(indexRow)
            let maxRows = numberOfRowsInSection(section: normalizedIndexRow.section)

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
