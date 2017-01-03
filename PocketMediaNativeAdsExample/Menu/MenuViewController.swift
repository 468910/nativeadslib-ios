//
//  MenuViewController.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 22/06/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
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
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        pocketMediaLogo.contentMode = .scaleAspectFit

        // Collection view button
        collectionViewAdsButton.titleEdgeInsets.left = 10
        collectionViewAdsButton.titleEdgeInsets.right = 10
        collectionViewAdsButton.titleLabel?.textColor = UIColor.white
        collectionViewAdsButton.layer.cornerRadius = 10
        collectionViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        collectionViewAdsButton.isHidden = true

        // TableViewButton
        tableViewAdsButton.layer.cornerRadius = 10
        tableViewAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)

        tableViewAdsButton.titleEdgeInsets.left = 10
        tableViewAdsButton.titleEdgeInsets.right = 10
        tableViewAdsButton.titleLabel?.textColor = UIColor.white

        // TableViewWithSections
        tableviewWithSectionsButton.layer.cornerRadius = 10
        tableviewWithSectionsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        tableviewWithSectionsButton.titleEdgeInsets.left = 10
        tableviewWithSectionsButton.titleEdgeInsets.right = 10
        tableviewWithSectionsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        tableviewWithSectionsButton.setTitle("TableViewWithSections", for: UIControlState.normal)

        // ScrollViewButton
        scrollViewButton.setTitle("ScrollView", for: UIControlState.normal)
        scrollViewButton.setTitleColor(UIColor.white, for: .normal)
        scrollViewButton.titleEdgeInsets.left = 10
        scrollViewButton.titleEdgeInsets.right = 10
        scrollViewButton.layer.cornerRadius = 10
        scrollViewButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        scrollViewButton.titleLabel?.textColor = UIColor.white
        scrollViewButton.isHidden = true

        // tableViewBigAdsButton

        tableviewBigAdsButton.setTitle("TableViewBigAdsButton", for: UIControlState.normal)
        tableviewBigAdsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        tableviewBigAdsButton.titleEdgeInsets.left = 10
        tableviewBigAdsButton.titleEdgeInsets.right = 10
        tableviewBigAdsButton.layer.cornerRadius = 10
        tableviewBigAdsButton.backgroundColor = UIColor(red: 11 / 255, green: 148 / 255, blue: 68 / 255, alpha: 1)
        tableviewBigAdsButton.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
