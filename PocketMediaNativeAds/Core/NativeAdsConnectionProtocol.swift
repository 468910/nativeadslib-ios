//
//  NativeAdsConnectionProtocol.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//
import Foundation

/**
 This delegate allows the invoking classes to react to native-ads related events
 */
@objc
public protocol NativeAdsConnectionDelegate {

    /**
     This method is invoked whenever while retrieving NativeAds an error has occured
     */
    func didReceiveError(error: NSError)

    @available(*, unavailable, renamed = "didReceiveResults")
    func didRecieveResults(nativeAds: [NativeAd])

    /**
     This method allows the delegate to receive a collection of NativeAds after making an NativeAdRequest.
     - nativeAds: Collection of NativeAds received after making a NativeAdRequest
     */
    func didReceiveResults(nativeAds: [NativeAd])

    /**
     Optional method, used in conjunction with the 'followRedirectsInBackground'.
     - adUnit: flag enabled in the NativeAdsRequest.
     */
    @available(*, deprecated = 1.0, obsoleted = 2.0, message = "This function is no longer used.")
    func didUpdateNativeAd(adUnit: NativeAd)
}
