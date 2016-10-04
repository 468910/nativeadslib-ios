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
    
    private var positions: [Int]
    private var currentIndex:Int = 0
    
    init(positions:[Int]) {
        //Remove duplicates and sort in ascending order.
        self.positions = Array(Set(positions)).sort { $0 < $1 }
    }
    
    public func reset() {
        currentIndex = 0
    }
    
    public func getAdPosition(maxSize: Int) throws -> NSNumber {
        if currentIndex >= positions.count {
            throw PredefinedAdPositionError.notEnoughPositions
        }
        var result = positions[currentIndex]
        currentIndex++
        return NSNumber(integer: result)
    }
    
}
