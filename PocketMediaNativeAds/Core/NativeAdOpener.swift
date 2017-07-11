//
//  BrowserProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import Foundation
/**
 An ad opener is a class responsible for opening an ad.
 */
@objc
public protocol NativeAdOpener: NativeAdsWebviewRedirectionsDelegate {
    /**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
    @objc
    func load(_ adUnit: NativeAd)
}
