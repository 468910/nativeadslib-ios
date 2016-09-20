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
    
    private var _adMargin:Int = 3
    public var adMargin: Int {
        set {
            _adMargin = newValue
        }
        get {
            return _adMargin
        }
    }
    
    // They are not called when variables are written to from an initializer or with a default value.
    private var _firstAdPosition:Int = 1
    public var firstAdPosition: Int {
        set {
            _firstAdPosition = newValue + 1
        }
        get {
            return _firstAdPosition
        }
    }

    public var adUnitType: AdUnitType = .Standard
    public var ads: [Int: NativeAd]!

    public override init() {
        super.init()
        self.ads = [Int: NativeAd]()
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
