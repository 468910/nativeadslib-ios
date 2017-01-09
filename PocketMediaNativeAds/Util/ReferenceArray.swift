//
//  ReferenceArray.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//
import Foundation

/**
 Accessing the internal PocketMediaNativeAds Framework Bundle
 */
@objc
open class PocketMediaNativeAdsBundle: NSObject {
    /**
     Returns the Bundle of the PocketMediaNativeAds framework.
     */
    open static func loadBundle() -> Bundle? {
        return Bundle(for: NativeAd.self)
    }
}
