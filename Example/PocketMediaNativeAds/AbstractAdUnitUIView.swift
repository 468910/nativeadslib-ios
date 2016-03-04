//
//  AbstractAdUnitUIView.swift
//  PocketMediaNativeAds
//
//  Created by apple on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class AbstractAdUnitUIView : UIView, NativeAdViewBinderProtocol {
  
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  
  
  public func configureAdView(nativeAd: NativeAd) {
    adTitle.text = nativeAd.campaignName
    adDescription.text = nativeAd.campaignDescription
    self.adImage.downloadedFrom(link: nativeAd.campaignImage.absoluteString, contentMode: .ScaleAspectFit)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    adDescription.numberOfLines = 0
    adDescription.lineBreakMode = .ByTruncatingTail
    adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.80
    
    adTitle.numberOfLines = 0
    adTitle.lineBreakMode = .ByTruncatingTail
    adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.70
    
  }
  
  
}