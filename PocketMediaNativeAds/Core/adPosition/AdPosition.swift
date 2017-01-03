//
//  adPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//
import Foundation

@objc
public protocol AdPosition {

    /**
     Called every time the positions are calculated. It resets the ad positioner.
     */
    func reset()

    /**
     Generates a unique position (integer) of where a new ad should be located.
     - Returns:
     a unique integer of where a new ad should be located.
     - Important:
     This method throws if it can't return a unique position
     */
    func getAdPosition(_ maxSize: Int) throws -> NSNumber

    /**
     Setter method to set self.adPositionOffset.
     - parameter position: The position of the first ad. Default is 0
     */
    func setadPositionOffset(_ position: Int)
}
