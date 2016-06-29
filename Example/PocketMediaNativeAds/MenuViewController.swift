//
//  MenuViewController.swift
//  PocketMediaNativeAds
//
//  Created by apple on 22/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke

class MenuViewController : UIViewController, UIPopoverPresentationControllerDelegate {
  
  @IBOutlet weak var collectionViewAdsButton: UIButton!
  @IBOutlet weak var tableViewAdsButton: UIButton!
  @IBOutlet weak var pocketMediaLogo: UIImageView!
  
  
  
  override func viewDidLoad() {
    let nav = self.navigationController?.navigationBar
    nav?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    
    collectionViewAdsButton.titleEdgeInsets.left = 10
    collectionViewAdsButton.titleEdgeInsets.right = 10
    collectionViewAdsButton.titleLabel?.textColor = UIColor.whiteColor()
    collectionViewAdsButton.layer.cornerRadius = 10
    collectionViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255,  alpha: 1)
    
    
    
    
    tableViewAdsButton.layer.cornerRadius = 10
    tableViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255,  alpha: 1)
    
    tableViewAdsButton.titleEdgeInsets.left = 10
    tableViewAdsButton.titleEdgeInsets.right = 10
    tableViewAdsButton.titleLabel?.textColor = UIColor.whiteColor()
    
    pocketMediaLogo.contentMode = .ScaleAspectFit
    
  }
  
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "popoverSegue" {
      let popoverViewController = segue.destinationViewController as! UIViewController
      popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
      popoverViewController.popoverPresentationController!.delegate = self
    }
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.None
  }
}