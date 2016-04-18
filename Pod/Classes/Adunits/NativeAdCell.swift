//
//  NativeAdCell.swift
//  PocketMediaNativeAds
//
//  Created by apple on 29/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class NativeAdCell : AbstractAdUnitTableViewCell {

    public override func configureAdView(nativeAd: NativeAd) {
        super.configureAdView(nativeAd);
        self.adTitle.font = UIFont(name: "MarkPro", size: 14)
        self.adDescription.font = UIFont(name: "MarkPro", size: 10)
        
        self.adImage.layer.cornerRadius = 5.0
        self.adImage.clipsToBounds = true

    }
    
}
  

  
  
  
