//
//  NativeAdCollectionCell.swift
//  Pods
//
//  Created by apple on 23/06/16.
//
//

import Foundation
import UIKit

public class NativeAdCollectionCell : UICollectionViewCell, NativeAdViewBinderProtocol  {
  @IBOutlet weak var adImage : UIImageView!
  
   public override func awakeFromNib() {
    super.awakeFromNib()
   }
  
  public func configureAdView(nativeAd: NativeAd) {
      self.adImage.downloadedFrom(link: nativeAd.campaignImage.absoluteString, contentMode: .ScaleAspectFit)
  }
  
  func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
    abort()
  }
  
}