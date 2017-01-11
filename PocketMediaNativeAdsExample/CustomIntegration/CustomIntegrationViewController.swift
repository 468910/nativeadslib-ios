//
//  CustomIntegration.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import UIKit
import PocketMediaNativeAds

class CustomIntegrationController: UIViewController, NativeAdsConnectionDelegate {
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adDescription: UILabel!

    var requester: NativeAdsRequest?
    var ad: NativeAd?

    var _requesting: Bool = false
    var requesting: Bool {
        get {
            return _requesting
        }
        set(newVal) {
            _requesting = newVal
            getButton.isEnabled = !_requesting
        }
    }

    override func viewDidLoad() {
        requester = NativeAdsRequest(adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", delegate: self)
        
        let click = UITapGestureRecognizer(target: self, action: #selector(tap(_:)) )
        adImage.addGestureRecognizer(click)
        adTitle.addGestureRecognizer(click)
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        ad?.openAdUrl(FullscreenBrowser(parentViewController: self))
    }

    /**
     Called the moment the user click on "get an ad"
     */
    @IBAction func getAd(_ sender: UIButton) {
        if requesting {
            return
        }
        requesting = true
        self.requester?.retrieveAds(1)
    }

    /**
     This method is invoked whenever while retrieving NativeAds an error has occured
     */
    func didReceiveError(_ error: Error) {
        requesting = false
        print(error)
    }

    /**
     This method allows the delegate to receive a collection of NativeAds after making an NativeAdRequest.
     - nativeAds: Collection of NativeAds received after making a NativeAdRequest
     */
    func didReceiveResults(_ nativeAds: [NativeAd]) {
        requesting = false
        showAd(ad: nativeAds[0])
    }

    /**
     Called to display an ad.
     */
    private func showAd(ad: NativeAd) {
        self.ad = ad
        adTitle.text = ad.campaignName
        adImage.nativeSetImageFromURL(ad.campaignImage)
        adDescription.text = ad.campaignDescription
    }
}
