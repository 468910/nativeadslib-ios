//
//  AboutUsViewController.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 10/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
    }

    @IBAction func openRepo(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://github.com/Pocketbrain/nativeadslib-ios")!)
    }

    @IBAction func openWebsite(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://nativeads.pocketmedia.mobi")!)
    }
}
