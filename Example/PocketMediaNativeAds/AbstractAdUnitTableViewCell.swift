//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by apple on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class AbstractAdUnitTableViewCell : UITableViewCell, NativeAdViewBinderProtocol {
  
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public func configureAdView(nativeAd: NativeAd) {
    adTitle.text = nativeAd.campaignName
    adDescription.text = nativeAd.campaignDescription
    self.adImage.downloadedFrom(link: nativeAd.campaignImage.absoluteString, contentMode: .ScaleAspectFit)
  }
  
  public override func awakeFromNib() {
      super.awakeFromNib()
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
