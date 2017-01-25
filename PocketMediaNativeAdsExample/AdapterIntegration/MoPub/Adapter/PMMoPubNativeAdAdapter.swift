//
//  PMMoPubNativeAdAdapter.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 23/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import MoPub
import PocketMediaNativeAds

/**
 Adapter for integration with MoPub. Wraps around the PockerMedia NativeAd model.
 Just copy this in your project. Do not edit, unless if you know what you're doing!
 See: https://github.com/mopub/mopub-ios-sdk/wiki/Custom-Events#quick-start-for-native-ads
 */
@objc(PMMoPubNativeAdAdapter)
open class PMMoPubNativeAdAdapter: NSObject, MPNativeAdAdapter, NativeAdOpenerDelegate {
    /**
     * Provides a dictionary of all publicly accessible assets (such as title and text) for the
     * native ad.
     *
     * When possible, you should place values in the returned dictionary such that they correspond to
     * the pre-defined keys in the MPNativeAdConstants header file.
     */
    public var properties: [AnyHashable : Any]

    
    weak open var delegate: MPNativeAdAdapterDelegate!
    
    let ad: NativeAd
    public init(ad: NativeAd) {
        
        self.ad = ad
        self.properties = [String : String]()
        properties[kAdTitleKey] = ad.campaignName
        properties[kAdTextKey] = ad.campaignDescription
        properties[kAdIconImageKey] = ad.campaignImage.absoluteString
        properties[kAdMainImageKey] = ad.bannerUrl()?.absoluteString
        properties[kAdCTATextKey] = ad.callToActionText
//        properties[kAdStarRatingKey] = 5
    }
    
    /**
     * The default click-through URL for the ad.
     *
     * This may safely be set to nil if your network doesn't expose this value (for example, it may only
     * provide a method to handle a click, lacking another for retrieving the URL itself).
     */
    open let defaultActionURL: URL? = nil
    
    /**
     * Determines whether MPNativeAd should track clicks
     *
     * If not implemented, this will be assumed to return NO, and MPNativeAd will track clicks.
     * If this returns YES, then MPNativeAd will defer to the MPNativeAdAdapterDelegate callbacks to
     * track clicks.
     */
    open func enableThirdPartyClickTracking() -> Bool {
        return false
    }
    
    /** @name Responding to an Ad Being Attached to a View */
    
    /**
     * This method will be called when your ad's content is about to be loaded into a view.
     *
     * @param view A view that will contain the ad content.
     *
     * You should implement this method if the underlying third-party ad object needs to be informed
     * of this event.
     */
    
    public func willAttach(to view: UIView!) {
        registerImpressionToMopub()
    }
    
    public func trackClick() {
        self.ad.openAdUrl(opener: FullScreenBrowser(delegate: self))
        //registerFinishHandlingClickToMopub()
    }
    
    /*
     Informs Mopub for the clicked registered
     */
    open func registerClickToMopub() {
        if let nativeAdDidClick = delegate.nativeAdDidClick {
            nativeAdDidClick(self)
        } else {
            print("Delegate does not implement the click tracking callback. Clicks are likely not tracked.")
        }
    }
    
    /*
     Informs Mopub for the impression registered
     */
    open func registerImpressionToMopub() {
        if let nativeAdWillLogImpression = delegate.nativeAdWillLogImpression {
            nativeAdWillLogImpression(self)
        } else {
            print("Delegate does not implement the impression tracking callback. Impressions are likely not tracked.")
        }
    }
    
    /*
     Informs Mopub that the web view is closed
     */
    open func registerFinishHandlingClickToMopub() {
        delegate.nativeAdDidDismissModal(for: self)
    }
    
    public func openerStopped() {
        registerFinishHandlingClickToMopub()
    }
    
    public func openerStarted() {
        registerClickToMopub()
    }
    
//    /*
//     Provides the adchoices view to mopub
//     */
//    open func privacyInformationIconView() -> UIView! {
//        let adChoicesView = UIImageView()
//        if let adChoices = ad.getAdChoices() {
//            adChoicesView.loadImage(adChoices.getIconUrl())
//            ad.registerAdChoicesListener(adChoicesView, ad: ad)
//        }
//        return adChoicesView
//    }
    
}
