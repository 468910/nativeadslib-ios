//
//  Constants.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 15/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

/**
  Information about the current platform/running device
*/
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
  Contains constants for the NativeAds
*/
public struct NativeAdsConstants {
  public struct Device {
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let model = UIDevice.currentDevice().model.characters.split{$0 == " "}.map { String($0) }[0]
  }
  public struct NativeAds {
    public static let tokenAdKey = "nativeAdToken"
    public static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
    public static let baseURLBeta = "http://offerwall.beta.pmgbrain.com/ow.php?output=json"
  }
}