//
//  MarginAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

/**
 Error this the MarginAdPosition can throw if asked for a position
 */
public enum MarginAdPositionError: Error {
    /// Invalid margin is set.
    case invalidmargin
}

/**
 This ad position implementation makes the ads show up at a set interval (margin).
 */
@objc
open class MarginAdPosition: NSObject, AdPosition {
    /// The margin (interval). Every x amount of position place an ad.
    fileprivate var margin: Int = 2
    /// The offset before an ad should appear.
    fileprivate var adPositionOffset: Int = -1
    /// The current value the positioner is at.
    fileprivate var currentValue: Int = 0

    /**
     Initializer.
     - parameter margin: The amount of entries before an ad. (default 2).
     - paramter adPositionOffset: The offset before an ad should appear.
     */
    public init(margin: Int = 2, adPositionOffset: Int = 0) {
        super.init()
        self.margin = margin + 1
        setadPositionOffset(adPositionOffset)
        reset()
    }

    /**
     Called every time the positions are calculated. It resets the ad positioner.
     */
    open func reset() {
        self.currentValue = adPositionOffset
    }

    /**
     Generates a unique position (integer) of where a new ad should be located.
     - Returns:
     a unique integer of where a new ad should be located.
     - Important:
     This method throws if it can't return a unique position
     */
    open func getAdPosition(_ maxSize: Int) throws -> NSNumber {
        if margin < 1 {
            throw MarginAdPositionError.invalidmargin
        }
        currentValue += margin
        return NSNumber(value: currentValue as Int)
    }

    /**
     Setter method to set self.adPositionOffset.
     - parameter position: The position of the first ad. Default is 0
     */
    open func setadPositionOffset(_ position: Int) {
        self.adPositionOffset = position < 0 ? 0 : position - 1
    }
}
