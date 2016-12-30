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

import UIKit
import Foundation

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
        static let iosVersion = NSString(string: UIDevice.current.systemVersion).doubleValue
        static let model = UIDevice.current.model.characters.split { $0 == " " }.map { String($0) }[0]
    }

    public struct NativeAds {
        public static let tokenAdKey = "nativeAdToken"
        public static let notifyBadAdsUrl = "https://nativeadsapi.pocketmedia.mobi/api.php"
        #if BETA
            public static let baseURL = "https://getnativebeta.pocketmedia.mobi/ow.php?output=json"
        #else
            public static let baseURL = "https://getnative.pocketmedia.mobi/ow.php?output=json"
        #endif
    }
}
