//
//  NativeAdInjector.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 01/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import PocketMediaNativeAds

public class NativeAdInjector : NSObject, NativeAdsConnectionDelegate{
  
  public var delegate : DisplayHelperDelegate
  public var collection : ReferenceArray<Any>
  
  public required init(collection : ReferenceArray<Any>, displayHelper: DisplayHelperDelegate){
    delegate = displayHelper
    self.collection = collection
  }
  
  @objc public func didRecieveError(error: NSError) {
    
  }
  
  @objc public func didRecieveResults(nativeAds: [NativeAd]) {
    nativeAds.forEach {
       collection.collection.insert($0, atIndex: Int(arc4random_uniform(UInt32(collection.collection.count))))
    }
    delegate.onUpdateCollection()
  }
  
  @objc public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
  
}