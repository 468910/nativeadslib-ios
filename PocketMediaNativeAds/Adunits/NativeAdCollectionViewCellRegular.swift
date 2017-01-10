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
    public func render(_ nativeAd: NativeAd) {
        self.adImage?.nativeSetImageFromURL(nativeAd.campaignImage)
    }
}
