//
//  Constants.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 15/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
let deviceModel = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
    if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
        return nil
    }
    return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))))
}

struct Constants {
  static let DummyFile = "DummyData"
  struct Device {
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let model : String? = deviceModel
  }
  struct NativeAds {
    static let tokenAdKey = "nativeAdToken"
    static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
    static let affiliateId = "XXXXXXXXXXXXXXXXX"
  }
}