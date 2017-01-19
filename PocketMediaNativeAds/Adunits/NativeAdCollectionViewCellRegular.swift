//
//  NativeAdCollectionViewCell.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 10/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

public class NativeAdCollectionViewCellRegular: UICollectionViewCell, NativeViewCell {
    @IBOutlet weak var adImage: UIImageView!

    /**
     Called to define what ad should be shown.
     */
    open func render(_ nativeAd: NativeAd, completion handler: @escaping ((Bool) -> Swift.Void)) {
        self.adImage?.nativeSetImageFromURL(nativeAd.campaignImage, completion: handler)
    }
}
