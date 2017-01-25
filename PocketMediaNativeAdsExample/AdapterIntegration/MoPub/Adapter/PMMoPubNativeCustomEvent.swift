//
//  PMMoPubNativeCustomEvent.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 23/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import MoPub
import PocketMediaNativeAds

enum PMMoPubNativeError: String, Error {
    case NoPlacementKey = "No placement key submitted"
}

/**
 Adapter for integration with MoPub. Wraps around the events from MoPub and calls the PocketMedia library.
 Just copy this in your project. Do not edit, unless if you know what you're doing!
 */
@objc(PMMoPubNativeCustomEvent)
open class PMMoPubNativeCustomEvent: MPNativeCustomEvent, NativeAdsConnectionDelegate {
    
    var requester: NativeAdsRequest?
    let lock = DispatchQueue(label: "com.PocketMedia.PMMoPubNativeCustomEvent")
    
    private func getNativeAdsRequestInstance(placementKey: String) -> NativeAdsRequest {
        if self.requester == nil {
            self.requester = NativeAdsRequest(adPlacementToken: placementKey, delegate: self)
        }
        return self.requester!
    }
    
    //PocketMedia ads we've received
    private var ads = [NativeAd]()
    /**
     The amount the integration wants
    */
    private var requestedNum = 0
    /**
     The amount we are requesting
    */
    private var requesting = 0
    
    /**
     * Called when the MoPub SDK requires a new native ad. Similar to custom integration.
     *
     * When the MoPub SDK receives a response indicating it should load a custom event, it will send
     * this message to your custom event class. Your implementation should load a native ad from a
     * third-party ad network.
     *
     * @param info A dictionary containing additional custom data associated with a given custom event
     * request. This data is configurable on the MoPub website, and may be used to pass dynamic
     * information, such as publisher IDs.
     */
    open override func requestAd(withCustomEventInfo info: [AnyHashable: Any]!) {
        guard let placementKey: String = (info["placementKey" as NSObject] as? String) else { didReceiveError(PMMoPubNativeError.NoPlacementKey); return }
        /*
         Because of the way PocketMedia saves impressions we can't request just one ad. We request several and use them the moment the integration asks for it.
         If this is not done, you'll end up with a situation where the same ad is returned twice before an impression is saved.
        */
        lock.sync() {
            //Increment the amount the integration wants.
            requestedNum += 1
            //If the amount the integration wants is lower than the amount we are requesting to our backend. Do a request
            if requesting <= requestedNum {
                let numWeNeed = (requestedNum - requesting) * 2 // Get twice more than we need
                requesting += numWeNeed
                let req = getNativeAdsRequestInstance(placementKey: placementKey)
                req.retrieveAds(UInt(numWeNeed))
            }
            didLoad()
        }
    }
    
    /**
     This method is invoked whenever while retrieving NativeAds an error has occured
     */
    public func didReceiveError(_ error: Error) {
        delegate.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForInvalidAdServerResponse(error.localizedDescription))
    }
    
    /**
     This method is invoked when we receive ads or the integration asks for it.
    */
    public func didLoad() {
        for _ in 0..<requestedNum {
            if let ad = ads.popLast() {
                requestedNum -= 1
                push(ad)
            } else {
                break
            }
        }
    }
    
    /**
     This method pushes a PocketMedia ad to the integration.
    */
    private func push(_ pmAd: NativeAd) {
        let adapter = PMMoPubNativeAdAdapter(ad: pmAd)
        let ad = MPNativeAd(adAdapter: adapter)
        
        var images = [NSURL]()
        if let icon = pmAd.iconUrl() {
            images.append(icon as NSURL)
        }
        if let banner = pmAd.bannerUrl() {
            images.append(banner as NSURL)
        }
        
        super.precacheImages(withURLs: images, completionBlock: { (error: [Any]?) in
            if ((error) != nil) {
                self.delegate.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForImageDownloadFailure())
            } else {
                self.delegate.nativeCustomEvent(self, didLoad: ad)
            }
        })
    }
    
    /**
     This method allows the delegate to receive a collection of NativeAds after making an NativeAdRequest.
     - nativeAds: Collection of NativeAds received after making a NativeAdRequest
     */
    public func didReceiveResults(_ nativeAds: [NativeAd]) {
        lock.sync() {
            ads.append(contentsOf: nativeAds)
            didLoad()
        }
    }
    
}
