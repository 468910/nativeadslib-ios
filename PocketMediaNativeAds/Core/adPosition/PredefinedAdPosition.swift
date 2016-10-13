//
//  PredefinedAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

public enum PredefinedAdPositionError: Error {
    case notEnoughPositions
}

@objc
public class PredefinedAdPosition: NSObject, AdPosition {
    
    fileprivate var positions: [Int] = []
    fileprivate var adPositionOffset: Int = 0
    fileprivate var currentIndex:Int = 0
    
    public init(positions:[Int], adPositionOffset: Int = 0) {
        super.init()
        //Remove duplicates and sort in ascending order.
        self.positions = Array(Set(positions)).sorted { $0 < $1 }
        setadPositionOffset(adPositionOffset)
        reset()
    }
    
    public func reset() {
        currentIndex = adPositionOffset
    }
    
    public func getAdPosition(_ maxSize: Int) throws -> NSNumber {
        if currentIndex >= positions.count {
            throw PredefinedAdPositionError.notEnoughPositions
        }
        let result = positions[currentIndex]
        currentIndex += 1
        return NSNumber(value: result as Int)
    }
    
    //Default is 0
    public func setadPositionOffset(_ position : Int) {
        self.adPositionOffset = position < 0 ? 0 : position
    }
    
}
