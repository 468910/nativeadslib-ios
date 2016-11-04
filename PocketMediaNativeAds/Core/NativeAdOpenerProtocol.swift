//
//  BrowserProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import Foundation
@objc
public protocol NativeAdOpenerDelegate: NativeAdsWebviewRedirectionsDelegate {
    /**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
    @objc
    func load(adUnit: NativeAd)
}
