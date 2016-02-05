//
//  Constants.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 15/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//


struct Platform {
    /**
      Utility method for deciding if using a real device or simulator
   
      - Returns: Bool indicating if using a real device or simulator
        true = Simulator false = Device
    */
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}


/**
  Contains Constants for the NativeAds
 
*/
public struct NativeAdsConstants {
  public static let DummyFile = "DummyData"
  public struct Device {
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let model = UIDevice.currentDevice().model.characters.split{$0 == " "}.map { String($0) }[0]
  }
  public struct NativeAds {
    public static let tokenAdKey = "nativeAdToken"
    public static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
  }
}