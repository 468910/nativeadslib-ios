//
//  NativeAdTableViewCellBig.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 10/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import UIKit

class NativeAdTableViewCellBig: NativeAdTableViewCellRegular {
    
    @IBOutlet weak var banner: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**
     Called to define what ad should be shown.
     */
    open override func render(_ nativeAd: NativeAd) {
        super.render(nativeAd)
        
        if let bannerUrl = nativeAd.bannerUrl() {
            banner.nativeSetImageFromURL(bannerUrl)
            bannerUrl.fetchImage({ downloadedImage in
                
            })
        }
    }

}
