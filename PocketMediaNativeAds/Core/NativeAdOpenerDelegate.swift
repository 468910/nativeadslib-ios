//
//  NativeAdOpenerDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 25/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 Delegate which needs to be informed about the status of the opener.
 */
@objc
public protocol NativeAdOpenerDelegate {
    // Called when the opener starts
    func openerStarted()
    // Called when the opener stops
    func openerStopped()
}
