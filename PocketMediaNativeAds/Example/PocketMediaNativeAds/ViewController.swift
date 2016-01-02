//
//  ViewController.swift
//  PocketMediaNativeAds
//
//  Created by Adrián Moreno Peña on 01/02/2016.
//  Copyright (c) 2016 Adrián Moreno Peña. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class ViewController: UIViewController, NativeAdConnectionProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK : - Native Ads Protocol
    
    func didRecieveError(error: NSError){
        print(error.description)
    }
    
    func didRecieveResults(nativeAds: [NativeAd]){
        
    }
    
}

