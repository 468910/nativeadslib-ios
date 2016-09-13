//
//  helpers.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation

class testHelpers {
    
    //Return a valid dict please.
    static func getNativeAdData() -> [String: AnyObject] {
        return [
            "campaign_name": "tests",
            "click_url": "http://PocketMedia.mobi/lovely/tests",
            "campaign_description": "",
            "id": "123",
            "default_icon": "http://google.co.uk",
            "images": NSDictionary()
        ]
    }
}