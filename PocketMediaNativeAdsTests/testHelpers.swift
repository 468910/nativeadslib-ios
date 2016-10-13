//
//  helpers.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation

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

    //Return a valid dict please.
    static func getNativeAdData() -> NSMutableDictionary? {
        if let ads = getNativeAdsData() {
            return ads[0] as? NSMutableDictionary
        }
        return nil
    }
}
