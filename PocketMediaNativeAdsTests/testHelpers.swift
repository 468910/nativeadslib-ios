//
//  helpers.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation
import PocketMediaNativeAds

class testHelpers {

    static func getNativeAdsData() -> [NSMutableDictionary]? {
        if let file = NSBundle(forClass: NativeAdsRequestTest.self).pathForResource("Tests", ofType: "json") {
            if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: file)!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                let ads = json.filter({
                    ($0 as? NSDictionary) != nil
                })
                return (ads as? [NSMutableDictionary])!
            }
        }
        return nil
    }

    // Return a valid dict please.
    static func getNativeAdData() -> NSMutableDictionary? {
        if let ads = getNativeAdsData() {
            return ads[0]
        }
        return nil
    }

    static func getNativeAd() -> NativeAd {
        let adDictionary = testHelpers.getNativeAdData()
        var nativeAd: NativeAd?
        do {
            nativeAd = try NativeAd(adDictionary: adDictionary!, adPlacementToken: "123")
        } catch {
            print("Could not create an instance of nativeAd")
        }
        return nativeAd!
    }
}
