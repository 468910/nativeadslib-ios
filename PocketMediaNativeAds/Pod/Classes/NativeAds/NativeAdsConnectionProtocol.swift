//
//  NativeAdsConnectionProtocol.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//


public protocol NativeAdsConnectionProtocol {
    func didRecieveError(error: NSError)
    func didRecieveResults(nativeAds: [NativeAd])
}
