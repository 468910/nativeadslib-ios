//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit

/**
 Protocol to define what each ad unit cell should contain method wise.
 */
public protocol NativeViewCell {
    /**
     Called to define what ad should be shown.
     */
    func render(_ nativeAd: NativeAd)
}
