//
//  PredefinedAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation
/**
 Errors that can be thrown by this positioner.
 */
public enum PredefinedAdPositionError: Error {
    case notEnoughPositions
}

@objc
open class PredefinedAdPosition: NSObject, AdPosition {
    /// array of positions where ads should be.
    fileprivate var positions: [Int] = []
    /// The offset before an ad should appear.
    fileprivate var adPositionOffset: Int = 0
    /// The current value the positioner is at.
    fileprivate var currentIndex: Int = 0

    /**
     Initializer.
     - parameter positions: array of positions where ads should be.
     - paramter adPositionOffset: The offset before an ad should appear.
     */
    public init(positions: [Int], adPositionOffset: Int = 0) {
        super.init()
        // Remove duplicates and sort in ascending order.
        self.positions = Array(Set(positions)).sorted { $0 < $1 }
        setadPositionOffset(adPositionOffset)
        reset()
    }

    /**
     Called every time the positions are calculated. It resets the ad positioner.
     */
    open func reset() {
        currentIndex = adPositionOffset
    }

    /**
     Generates a unique position (integer) of where a new ad should be located.
     - Returns:
     a unique integer of where a new ad should be located.
     - Important:
     This method throws if it can't return a unique position
     */
    open func getAdPosition(_ maxSize: Int) throws -> NSNumber {
        if currentIndex >= positions.count {
            throw PredefinedAdPositionError.notEnoughPositions
        }
        let result = positions[currentIndex]
        currentIndex += 1
        return NSNumber(value: result as Int)
    }

    /**
     Setter method to set self.adPositionOffset.
     - parameter position: The position of the first ad. Default is 0
     */
    open func setadPositionOffset(_ position: Int) {
        self.adPositionOffset = position < 0 ? 0 : position
    }
}
