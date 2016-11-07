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
        if let file = Bundle(for: NativeAdsRequestTest.self).path(forResource: "Tests", ofType: "json") {
            do {
                var data:Data
                data = try Data(contentsOf: URL(fileURLWithPath: file))
                
                if let json: NSArray = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) ) as? NSArray {
                    let ads = json.filter({
                        ($0 as? NSDictionary) != nil
                    })
                    return (ads as? [NSMutableDictionary])!
                }
            }catch let ex {
                print("Error info: \(ex)")
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

    private static func createNativeAd(dict: NSMutableDictionary) -> NativeAd! {
        var nativeAd: NativeAd?
        do {
            nativeAd = try NativeAd(adDictionary: dict, adPlacementToken: "123")
        } catch {
            print("Could not create an instance of nativeAd")
        }
        return nativeAd!
    }

    static func getNativeAd() -> NativeAd {
        let adDictionary = testHelpers.getNativeAdData()
        return testHelpers.createNativeAd(adDictionary!)
    }

    static func getNativeAds() -> [NativeAd] {
        let adsDicts = getNativeAdsData()
        var results = [NativeAd]()
        for adDict in adsDicts! {
            results.append(createNativeAd(adDict))
        }
        return results
    }
}
