//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke


/**
 Class that is used to open the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpenerProtocol
 **/
public class AbstractAdUnitTableViewCell : UITableViewCell, NativeAdViewBinderProtocol {
  
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  
  
  
  public func configureAdView(nativeAd: NativeAd) {
    adTitle.text = nativeAd.campaignName
    adDescription.text = nativeAd.campaignDescription
    print(nativeAd.campaignImage)
    adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
  }
  func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
    abort()
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



