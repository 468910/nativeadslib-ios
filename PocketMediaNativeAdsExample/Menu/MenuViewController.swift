//
//  MenuViewController.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 22/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var collectionViewAdsButton: UIButton!
    @IBOutlet weak var tableViewAdsButton: UIButton!
    @IBOutlet weak var scrollViewButton: UIButton!
    @IBOutlet weak var pocketMediaLogo: UIImageView!
    @IBOutlet weak var tableviewBigAdsButton: UIButton!
    @IBOutlet weak var tableviewWithSectionsButton: UIButton!

    override func viewDidLoad() {
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        pocketMediaLogo.contentMode = .ScaleAspectFit

        // Collection view button
        collectionViewAdsButton.titleEdgeInsets.left = 10
        collectionViewAdsButton.titleEdgeInsets.right = 10
        collectionViewAdsButton.titleLabel?.textColor = UIColor.whiteColor()
        collectionViewAdsButton.layer.cornerRadius = 10
        collectionViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        collectionViewAdsButton.hidden = true

        // TableViewButton
        tableViewAdsButton.layer.cornerRadius = 10
        tableViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)

        tableViewAdsButton.titleEdgeInsets.left = 10
        tableViewAdsButton.titleEdgeInsets.right = 10
        tableViewAdsButton.titleLabel?.textColor = UIColor.whiteColor()

        // TableViewWithSections
        tableviewWithSectionsButton.layer.cornerRadius = 10
        tableviewWithSectionsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        tableviewWithSectionsButton.titleEdgeInsets.left = 10
        tableviewWithSectionsButton.titleEdgeInsets.right = 10
        tableviewWithSectionsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tableviewWithSectionsButton.setTitle("TableViewWithSections", forState: UIControlState.Normal)

        // ScrollViewButton
        scrollViewButton.setTitle("ScrollView", forState: UIControlState.Normal)
        scrollViewButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        scrollViewButton.titleEdgeInsets.left = 10
        scrollViewButton.titleEdgeInsets.right = 10
        scrollViewButton.layer.cornerRadius = 10
        scrollViewButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        scrollViewButton.titleLabel?.textColor = UIColor.whiteColor()
        scrollViewButton.hidden = true

        // tableViewBigAdsButton

        tableviewBigAdsButton.setTitle("TableViewBigAdsButton", forState: UIControlState.Normal)
        tableviewBigAdsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tableviewBigAdsButton.titleEdgeInsets.left = 10
        tableviewBigAdsButton.titleEdgeInsets.right = 10
        tableviewBigAdsButton.layer.cornerRadius = 10
        tableviewBigAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        tableviewBigAdsButton.hidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destinationViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
