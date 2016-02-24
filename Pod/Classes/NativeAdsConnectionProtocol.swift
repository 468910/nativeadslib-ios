//
//  NativeAdsConnectionProtocol.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//

/**
  This delegate allows the invoking classes to react to native-ads related events
*/
@objc
public protocol NativeAdsConnectionDelegate {
  
    /**
        This method is invoked whenever while retrieving NativeAds an error has occured
    */
    func didRecieveError(error: NSError)
  
    /**
        This method allows the delegate to receive a collection of NativeAds after making an NativeAdRequest.
        - nativeAds: Collection of NativeAds received after making a NativeAdRequest
    */
    func didRecieveResults(nativeAds: [NativeAd])
  
    /**
        Optional method, used in conjunction with the 'followRedirectsInBackground'.
        - adUnit: flag enabled in the NativeAdsRequest.
    */
    func didUpdateNativeAd(adUnit : NativeAd)
}

extension NativeAdsConnectionDelegate{
    func didUpdateNativeAd(adUnit : NativeAd){}
}