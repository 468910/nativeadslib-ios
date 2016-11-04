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
public class AbstractAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {
    private(set) public var ad: NativeAd?

    public func render(nativeAd: NativeAd) {
        self.ad = nativeAd
    }

    // After has been loaded from Nib
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
