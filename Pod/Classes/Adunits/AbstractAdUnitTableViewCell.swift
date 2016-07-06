//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AlamofireImage
import Haneke
import Darwin

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
    
    
    
    /*if(self.adDescription.frame.maxY > self.adImage.frame.maxY){
      var point = CGPoint(x: adDescription.frame.origin.x, y: adImage.frame.maxY - adDescription.frame.origin.y)
      self.adDescription.frame = CGRectMake(point.x, point.y, adDescription.frame.width,
                                            abs(adImage.frame.maxY - adDescription.frame.origin.y))
        centerAlignY.active = false
    }*/
  
  }
  
  
  
  public override func updateConstraints() {
    super.updateConstraints()
    print("Current addescription height")
    /**
    if(self.adDescription.frame.height > 16){
      centerAlignY = MyConstraint.changeMultiplier(centerAlignY, multiplier: 0.5)
    }else {
      centerAlignY = MyConstraint.changeMultiplier(centerAlignY, multiplier: 1)
    }*/
    
   
      

    
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


extension UIImageView {
  func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
    guard
      let url = NSURL(string: link)
      else {return}
    contentMode = mode
    NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
      guard
        let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
        let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
        let data = data where error == nil,
        let image = UIImage(data: data)
        else { return }
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        self.image = image
      }
    }).resume()
  }
}
