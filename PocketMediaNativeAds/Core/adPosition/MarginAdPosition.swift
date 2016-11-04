//
//  MarginAdPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

public enum MarginAdPositionError: ErrorType {
    case invalidmargin
}

@objc
public class MarginAdPosition: NSObject, AdPosition {

    private var margin: Int = 2
    private var adPositionOffset: Int = -1
    private var currentValue: Int = 0

    public init(margin: Int = 2, adPositionOffset: Int = 0) {
        super.init()
        self.margin = margin + 1
        setadPositionOffset(adPositionOffset)
        reset()
    }

    public func reset() {
        self.currentValue = adPositionOffset
    }

    public func getAdPosition(maxSize: Int) throws -> NSNumber {
        if margin < 1 {
            throw MarginAdPositionError.invalidmargin
        }
        currentValue += margin
        return NSNumber(integer: currentValue)
    }

    //Default is 0
    public func setadPositionOffset(position: Int) {
        self.adPositionOffset = position < 0 ? 0 : position - 1
    }

}
