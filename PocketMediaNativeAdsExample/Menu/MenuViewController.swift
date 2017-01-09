//
//  MenuViewController.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 22/06/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var pocketMediaLogo: UIImageView!

    override func viewDidLoad() {
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        pocketMediaLogo.contentMode = .scaleAspectFit
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
