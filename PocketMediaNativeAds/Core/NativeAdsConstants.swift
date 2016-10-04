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
		static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
		static let model = UIDevice.currentDevice().model.characters.split { $0 == " " }.map { String($0) }[0]
	}
	public struct NativeAds {
        public static let tokenAdKey = "nativeAdToken"
		public static let notifyBadAdsUrl = "http://nativeadsapi.pocketmedia.mobi/api.php"
		public static let userToken = "978d0f4b08ec25a8c32a2de208c23acbbfb3fb465b66e51fd79194fb0a6811e1"
        #if BETA
            public static let baseURL = "http://offerwall.beta.pmgbrain.com/ow.php?output=json"
            // public static let baseURL = "http://offerwall.kinson.sandbox.pmgbrain.com/ow.php?output=json"
        #else
            public static let baseURL = "http://offerwall.12trackway.com/ow.php?output=json"
        #endif

		public static let redirectionOfferEngineUrl = "http://www.trckperformance.com/campaign.php?csrc=trpro&ad=24506&aff_id=2854&aff_sub={affiliate_sub}&aff_sub2={affiliate_sub2}&aff_sub3={affiliate_sub3}&aff_sub4={affiliate_sub4}"
	}
}
