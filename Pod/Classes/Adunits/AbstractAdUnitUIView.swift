//
//  AbstractAdUnitUIView.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke

// Removed designated Initializer because the way Objective C works, when defining an designated Objective C wont automatically inherit all the super class initializers!
@objc
public class AbstractAdUnitUIView : UIView,  NativeAdViewBinderProtocol{
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  var tapGesture : UITapGestureRecognizer?
  
  var viewController : UIViewController?
  var nativeAd: NativeAd?
  
  
  public func configureAdView(nativeAd: NativeAd) {
    tapGesture = UITapGestureRecognizer(target:nativeAd , action: "openAdUrlInForeground");
    setupAdView(nativeAd)
  }
  
  func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
    
    self.viewController = viewController
    self.nativeAd = nativeAd
    
    tapGesture = UITapGestureRecognizer(target:self , action: "openAdUrl");
    setupAdView(nativeAd)
    
  }
  
  
  public func openAdUrl(){
   FullscreenBrowser(parentViewController: viewController!).load(nativeAd!)
  }
  
  func setupAdView(nativeAd: NativeAd){
    
    self.addGestureRecognizer(self.tapGesture!)
    self.userInteractionEnabled = true
    
    adTitle.text = nativeAd.campaignName
    adDescription.text = nativeAd.campaignDescription
    self.adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
  }
  
  
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    
    adDescription.numberOfLines = 0
    adDescription.lineBreakMode = .ByTruncatingTail
    adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.60
    
    adTitle.numberOfLines = 0
    adTitle.lineBreakMode = .ByTruncatingTail
    adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.60
    
    
  }
  
}