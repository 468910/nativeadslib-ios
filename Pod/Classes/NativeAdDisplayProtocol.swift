//
//  NativeAdDisplayProtocol.swift
//  Pods
//
//  Created by apple on 18/02/16.
//
//

/**
  - Protocol for the opening of the Native ads
*/
@objc
public protocol NativeAdOpenerProtocol {
   /**
    - Method to be implemented which must contain  NativeAd opening logic.
   */
   func load(adUnit : NativeAd)
}
