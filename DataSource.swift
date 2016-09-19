//
//  DataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 19/09/16.
//
//

import Foundation

//TODO: When we have more than just tableviews. Simply this type and get rid of NativeAdTableViewDataSourceProtocol
@objc
public class DataSource: NSObject, DataSourceProtocol {

    public var adMargin: Int = 3 {
        willSet {
            if newValue >= 1 {
                adMargin = newValue
            } else {
                adMargin = 1
            }
        }
    }

    // they are not called when variables are written to from an initializer or with a default value.
    public var firstAdPosition: Int = 0 {
        willSet {
            firstAdPosition = newValue + 1
            Logger.debug("First Ad Position Changed Preparing for Updating Ad Positions")
        }
    }

    public var adUnitType: AdUnitType = .Standard
    public var ads: [Int: NativeAd]!

    public override init() {
        super.init()
        self.ads = [Int: NativeAd]()
    }

    @nonobjc
    public func setAdMargin(adMargin: Int = 2) {
        self.adMargin = adMargin + 1 // + 1 because [...]
    }

    @nonobjc
    public func setFirstAdPosition(firstAdPosition: Int = 0) {
        self.firstAdPosition = firstAdPosition
    }

    @nonobjc
    public func setAdUnitType(type: AdUnitType) {
        self.adUnitType = type
    }

    func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int) -> Int {
        return IndexRowNormalizer.getNumberOfRowsForSectionIncludingAds(numOfRowsInSection, totalRowsInSection: totalRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: ads.count)
    }

    public func onUpdateDataSource() {
        preconditionFailure("This method must be overridden")
    }

    public func getTruePosistionInDataSource(indexPath: NSIndexPath) -> Int {
        preconditionFailure("This method must be overridden")
    }

    public func numberOfElements() -> Int {
        preconditionFailure("This method must be overridden")
    }

    func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        let position = getTruePosistionInDataSource(indexPath)
        if let val = ads[position] {
            return val
        } else {
            return nil
        }
    }

}
