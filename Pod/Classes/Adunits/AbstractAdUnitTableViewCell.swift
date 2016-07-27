//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke
import Darwin


/**
 Class to be subclassed for use with the AdStream.
 **/
public class AbstractAdUnitTableViewCell : UITableViewCell, NativeAdViewBinderProtocol {
  
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  @IBOutlet weak var adInfoView: UIView!
  
  @IBOutlet weak var adDescriptionHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var middleLineCenterYConstraint: NSLayoutConstraint!
  
  
  public func configureAdView(nativeAd: NativeAd) {
    adTitle.text = nativeAd.campaignName
    adDescription.text = nativeAd.campaignDescription
    print(nativeAd.campaignImage)
    adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
  }
  
  func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
    abort()
  }
  
  
  // After has been loaded from Nib
  public override func awakeFromNib() {
      super.awakeFromNib()
      adDescription.numberOfLines = 0
      adDescription.lineBreakMode = .ByTruncatingTail
      adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.80
    
      adTitle.numberOfLines = 0
      adTitle.lineBreakMode = .ByTruncatingTail
      adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.70
    
    
      // Setting AdDescription And Adtitle
    

      self.adDescription.backgroundColor = UIColor.redColor()
      self.adTitle.backgroundColor = UIColor.yellowColor()
    
  
  
    
  }
 
  // Used to change subviews
  public override func layoutSubviews() {
  
    print("I'M invoked")
  }
  
  
  
  public override func updateConstraints() {
    super.updateConstraints()
    
    var lineCount = 0;
    let textSize = CGSizeMake(adDescription.frame.size.width, CGFloat(Float.infinity));
    let rHeight = lroundf(Float(adDescription.sizeThatFits(textSize).height))
    let charSize = lroundf(Float(adDescription.font.lineHeight));
    lineCount = rHeight/charSize
    print("No of lines \(lineCount)")
    
    if(lineCount > 1){
      
    }
    
    
    
   
      

    
  }
  
}

struct MyConstraint {
  static func changeMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
    let newConstraint = NSLayoutConstraint(
      item: constraint.firstItem,
      attribute: constraint.firstAttribute,
      relatedBy: constraint.relation,
      toItem: constraint.secondItem,
      attribute: constraint.secondAttribute,
      multiplier: multiplier,
      constant: constraint.constant)
    
    newConstraint.priority = constraint.priority
    
    NSLayoutConstraint.deactivateConstraints([constraint])
    NSLayoutConstraint.activateConstraints([newConstraint])
    
    return newConstraint
  }
}


