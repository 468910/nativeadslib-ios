//
//  NativeAdsConnectionProtocol.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//


@objc
public protocol NativeAdsConnectionProtocol {
    
    @objc
    func didRecieveError(error: NSError)
    
    @objc
    func didRecieveResults(nativeAds: [NativeAd])
  
    // Optional method, used in conjunction with the 'followRedirectsInBackground'
    // flag enabled in the NativeAdsRequest
    @objc
    func didUpdateNativeAd(adUnit : NativeAd)
}

extension NativeAdsConnectionProtocol{
    func didUpdateNativeAd(adUnit : NativeAd){}
}
