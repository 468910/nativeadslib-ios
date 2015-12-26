//
//  Constants.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 15/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

struct Constants {
  static let DummyFile = "DummyData"
  struct Device {
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let model = UIDevice.currentDevice().model.characters.split{$0 == " "}.map { String($0) }[0]
  }
  struct NativeAds {
    static let tokenAdKey = "nativeAdToken"
    static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
    static let affiliateId = "XXXXXXXXXXXXXXXXX"
  }
}