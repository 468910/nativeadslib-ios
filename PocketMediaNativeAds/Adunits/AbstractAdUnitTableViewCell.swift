//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

/**
 Class to be subclassed for use with the AdStream.
 **/
open class AbstractAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {
    fileprivate(set) open var ad: NativeAd?

    open func render(_ nativeAd: NativeAd) {
        self.ad = nativeAd
    }

    // After has been loaded from Nib
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}
