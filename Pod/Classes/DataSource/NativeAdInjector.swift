//
//  NativeAdInjector.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 01/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

@objc
/**
  Classs that given Any Collection injects native
**/
public class NativeAdInjector : NSObject, NativeAdsConnectionDelegate{
  
  public var delegate : DisplayHelperDelegate
  public var collection : ReferenceArray<Any>
  
  public required init(collection : ReferenceArray<Any>, displayHelper: DisplayHelperDelegate){
    delegate = displayHelper
    self.collection = collection
  }
  
  public func didRecieveError(error: NSError) {
    
  }
  
  public func didRecieveResults(nativeAds: [NativeAd]) {
    nativeAds.forEach {
       collection.collection.insert($0, atIndex: Int(arc4random_uniform(UInt32(collection.collection.count))))
    }
    delegate.onUpdateCollection()
  }
  
  public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
  
}