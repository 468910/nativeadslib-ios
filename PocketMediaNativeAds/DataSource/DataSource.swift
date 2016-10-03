//
//  DataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 19/09/16.
//  This class is a abstract class that contains all important stuff that the datasources will have alike.
//

import Foundation

@objc
public class DataSource: NSObject, DataSourceProtocol {
    
    //The admargin is the frequency of how many times a ad is shown in the datasource.
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
    
    //The AdUnitType defines what kind of ad is shown.
    public var adUnitType: AdUnitType = .Standard

  
    
    public func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        preconditionFailure("This method must be overriden")
    }
    
    
    //Abstract classes that a datasource should override
    public func onUpdateDataSource(newAds: [NativeAd]) {
        preconditionFailure("This method must be overridden")
    }

    public func getTruePositionInDataSource(indexPath: NSIndexPath) -> Int {
        preconditionFailure("This method must be overridden")
    }

    public func numberOfElements() -> Int {
        preconditionFailure("This method must be overridden")
    }
    
}
