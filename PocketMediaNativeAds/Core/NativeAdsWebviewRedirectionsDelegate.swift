//
//  NativeAdsWebviewRedirectionsDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 12/09/16.
//
//

import Foundation

/**
 Protocol to be implemented by the classes that want to implement some behaviour
 when the final url was opened in the external browser (this will usually an app store one)
 */
@objc
public protocol NativeAdsWebviewRedirectionsDelegate {
    /// Will be invoked when the external browser is opened with the final URL
    func didOpenBrowser(url: NSURL)
}