//
//  MenuViewController.swift
//  PocketMediaNativeAds
//
//  Created by apple on 22/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke

class MenuViewController : UIViewController {
  
  @IBOutlet weak var collectionViewAdsButton: UIButton!
  @IBOutlet weak var tableViewAdsButton: UIButton!
  @IBOutlet weak var pocketMediaLogo: UIImageView!
  
  
  
  override func viewDidLoad() {
    collectionViewAdsButton.layer.borderColor = UIColor.blackColor().CGColor
    collectionViewAdsButton.layer.borderWidth = 2
    collectionViewAdsButton.titleEdgeInsets.left = 10
    collectionViewAdsButton.titleEdgeInsets.right = 10
    
    tableViewAdsButton.layer.borderColor = UIColor.blackColor().CGColor
    tableViewAdsButton.layer.borderWidth = 2
    tableViewAdsButton.titleEdgeInsets.left = 10
    tableViewAdsButton.titleEdgeInsets.right = 10
    
    pocketMediaLogo.contentMode = .ScaleAspectFit
    pocketMediaLogo.hnk_setImageFromURL(NSURL(string: "http://www.pocketmedia.mobi/assets/logo-034cf96908f238260a65b46ecefadeed.png")!)
  }
}