//
//  NativeAdCell.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 29/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

/**
 Standard AdUnit for TableView
 **/
public class NativeAdCell : AbstractAdUnitTableViewCell {
  
  @IBOutlet weak var installButton: UIButton!
 
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    adImage.layer.cornerRadius = CGRectGetWidth(adImage.frame) / 10
    adImage.layer.masksToBounds = true
   
    
    
    
    
    installButton.layer.borderColor = self.tintColor.CGColor
    installButton.layer.borderWidth = 1
    installButton.layer.masksToBounds = true
    installButton.layer.cornerRadius = CGRectGetWidth(adImage.frame) / 20
    installButton.titleLabel?.baselineAdjustment = .AlignCenters
    installButton.titleLabel?.textAlignment = .Center
    installButton.titleLabel?.minimumScaleFactor = 0.1
    
    var color = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 67.0/255.0, alpha: 1)
    installButton.setTitleColor(color, forState: .Normal)
    installButton.layer.borderColor = color.CGColor
    
    
    
    installButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5,  bottom: 0,  right: 5)
    
    
    
    installButton.titleLabel?.minimumScaleFactor = 0.50
    installButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    
    
    
  }
}
  

  
  
  
