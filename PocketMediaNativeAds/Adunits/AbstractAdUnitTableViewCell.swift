//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit

/**
 Class to be subclassed for use with the AdStream.
 */
open class AbstractAdUnitTableViewCell: UITableViewCell {
    /// The ad shown in this cell.
    fileprivate(set) open var ad: NativeAd?

    /// Called to define what ad should be shown.
    open func render(_ nativeAd: NativeAd) {
        self.ad = nativeAd
    }

    /// After has been loaded from Nib
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}
