//
//  NativeAdCell.swift
//  PocketMediaNativeAds
//
//  Created by apple on 29/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class NativeAdCell : UITableViewCell {
  
  @IBOutlet weak var adImage: UIImageView!
  @IBOutlet weak var adName: UILabel!
  @IBOutlet weak var adDescription: UILabel!
  @IBOutlet weak var speakerPhone: UIImageView!
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func awakeFromNib() {
    adName.text = "Amazing Ad"
    adName.lineBreakMode = .ByWordWrapping
    adName.sizeToFit()
    
    adDescription.text = "This ad is so cool"
    adDescription.lineBreakMode = .ByWordWrapping
    adDescription.sizeToFit()
    
    
    super.awakeFromNib()
    
  }
  
  public func configureFromNativeAd(adUnit: NativeAd){
    self.adName.text = adUnit.campaignName
    self.adDescription.text = adUnit.campaignDescription
    self.adImage.downloadedFrom(link: adUnit.campaignImage.absoluteString, contentMode: .Redraw)
    
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