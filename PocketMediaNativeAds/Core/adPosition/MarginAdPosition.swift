//
//  MarginAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

public enum MarginAdPositionError: Error {
    case invalidmargin
}

@objc
public class MarginAdPosition: NSObject, AdPosition {
    
    fileprivate var margin: Int = 2
    fileprivate var adPositionOffset: Int = -1
    fileprivate var currentValue: Int = 0
    
    public init(margin:Int = 2, adPositionOffset: Int = 0) {
        super.init()
        self.margin = margin + 1
        setadPositionOffset(adPositionOffset)
        reset()
    }
    
    public func reset() {
        self.currentValue = adPositionOffset
    }
    
    public func getAdPosition(_ maxSize: Int) throws -> NSNumber {
        if margin < 1 {
            throw MarginAdPositionError.invalidmargin
        }
        currentValue += margin
        return NSNumber(value: currentValue as Int)
    }
    
    //Default is 0
    public func setadPositionOffset(_ position : Int) {
        self.adPositionOffset = position < 0 ? 0 : position - 1
    }
    
}
