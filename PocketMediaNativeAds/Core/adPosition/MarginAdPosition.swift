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
    private var currentValue:Int = -1
    
    init(margin:Int) {
        self.margin = margin + 1
    }
    
    public func reset() {
        currentValue = -1
    }
    
    public func getAdPosition(maxSize: Int) throws -> NSNumber {
        if margin < 1 {
            throw MarginAdPositionError.invalidmargin
        }
        currentValue += margin
        return NSNumber(integer: currentValue)
    }
    
}
