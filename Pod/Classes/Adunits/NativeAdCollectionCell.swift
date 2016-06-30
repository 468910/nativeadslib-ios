//
//  NativeAdCollectionCell.swift
//  Pods
//
//  Created by Pocket Media on 23/06/16.
//
//

import Foundation
import UIKit
import Haneke

public class NativeAdCollectionCell : UICollectionViewCell, NativeAdViewBinderProtocol  {
  @IBOutlet weak var adImage : UIImageView!
  
   public override func awakeFromNib() {
    super.awakeFromNib()
   }
  
  public func configureAdView(nativeAd: NativeAd) {
      self.adImage.hnk_setImageFromURL(nativeAd.campaignImage)
  }
  
  func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
    abort()
  }
  
}