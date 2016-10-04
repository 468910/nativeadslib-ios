//
//  adPosition.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/10/2016.
//
//

import Foundation

//TODO: Bring back first ad position.
@objc
public protocol AdPosition {
    
    //Called every time the positions are calculated
    func reset()
    
    //Should return a unique integer of where a new ad should be located.
    func getAdPosition(maxSize:Int) throws -> NSNumber
}
