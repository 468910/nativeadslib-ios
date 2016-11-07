//
//  ReferenceArray.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
// Note This is Added because Arrays are copied by value. But why!?

import UIKit

/**
 - Acessing the internal PocketMediaNativeAds Framework Bundle
 **/
@objc
open class PocketMediaNativeAdsBundle: NSObject {
    open static func loadBundle() -> Bundle? {
        return Bundle(for: NativeAd.self)
    }
}
