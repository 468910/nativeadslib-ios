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
    public var adUnitType: AdUnitType = .standard
    
    public func getNativeAdListing(_ indexPath: IndexPath) -> NativeAd? {
        if let val = adListings[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row]?.ad {
            return val
        }
        return nil
    }
    
    //Abstract classes that a datasource should override
    public func onAdRequestSuccess(_ newAds: [NativeAd]) {
        preconditionFailure("This method must be overridden")
    }

    public func getTruePositionInDataSource(_ indexPath: IndexPath) -> Int {
        preconditionFailure("This method must be overridden")
    }

    public func numberOfElements() -> Int {
        preconditionFailure("This method must be overridden")
    }
    
}
