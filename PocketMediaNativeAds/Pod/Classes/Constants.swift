//
//  Constants.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 15/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

public struct NativeAdsConstants {
  public static let DummyFile = "DummyData"
  public struct Device {
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let model = UIDevice.currentDevice().model.characters.split{$0 == " "}.map { String($0) }[0]
  }
  public struct NativeAds {
    public static let tokenAdKey = "nativeAdToken"
    public static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
    public static let affiliateId = "XXXXXXXXXXXXXXXXX"
  }
}