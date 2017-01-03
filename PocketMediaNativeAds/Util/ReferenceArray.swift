//
//  ReferenceArray.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

/**
 Accessing the internal PocketMediaNativeAds Framework Bundle
 */
@objc
open class PocketMediaNativeAdsBundle: NSObject {
    open static func loadBundle() -> Bundle? {
        return Bundle(for: NativeAd.self)
    }
}
