//
//  NativeAdDisplayProtocol.swift
//  Pods
//
//  Created by apple on 18/02/16.
//
//
import Foundation

/**
 Protocol for the opening of the Native ads.
 */
@objc
public protocol NativeAdOpenerDelegate {
    /**
     Method to be implemented which must contain  NativeAd opening logic.
     - adUnit: the ad unit whose url is to be opened
     */
    func load(adUnit : NativeAd)
}
