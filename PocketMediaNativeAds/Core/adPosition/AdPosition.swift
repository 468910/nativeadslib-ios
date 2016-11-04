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
    //Set the first ad position.
    func setadPositionOffset(position: Int)

    //Called every time the positions are calculated
    func reset()

    //Should return a unique integer of where a new ad should be located.
    func getAdPosition(maxSize: Int) throws -> NSNumber
}
