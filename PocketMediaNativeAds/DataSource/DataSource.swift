//
//  DataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 19/09/16.
//  This class is a abstract class that contains all important stuff that the datasources will have alike.
//

import Foundation

public struct NativeAdInfo {
    var ad : NativeAd
    var position : Int
}

public typealias AdsForSectionMap = [Int : [Int : NativeAdInfo]]

@objc
public class DataSource: NSObject, DataSourceProtocol {
    
    public var adListings: AdsForSectionMap = AdsForSectionMap()
    public var ads: [NativeAd] = [NativeAd]()
    
    //The AdUnitType defines what kind of ad is shown.
    public var adUnitType: AdUnitType = .Standard
    
    public func getNativeAdListing(indexPath: NSIndexPath) -> NativeAd? {
        if let val = adListings[indexPath.section]?[indexPath.row]?.ad {
            return val
        }
        return nil
    }
    
    //Abstract classes that a datasource should override
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
