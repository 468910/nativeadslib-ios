//
//  PredefinedAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

public enum PredefinedAdPositionError: ErrorType {
    case notEnoughPositions
}

@objc
public class PredefinedAdPosition: NSObject, AdPosition {
    
    private var positions: [Int] = []
    private var adPositionOffset: Int = 0
    private var currentIndex:Int = 0
    
    public init(positions:[Int], adPositionOffset: Int = 0) {
        super.init()
        //Remove duplicates and sort in ascending order.
        self.positions = Array(Set(positions)).sort { $0 < $1 }
        setadPositionOffset(adPositionOffset)
        reset()
    }
    
    public func reset() {
        currentIndex = adPositionOffset
    }
    
    public func getAdPosition(maxSize: Int) throws -> NSNumber {
        if currentIndex >= positions.count {
            throw PredefinedAdPositionError.notEnoughPositions
        }
        let result = positions[currentIndex]
        currentIndex += 1
        return NSNumber(integer: result)
    }
    
    //Default is 0
    public func setadPositionOffset(position : Int) {
        self.adPositionOffset = position < 0 ? 0 : position
    }
    
}
