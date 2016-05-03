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
public class NativeAdsRetriever : NSObject, NativeAdsConnectionDelegate{
  
  public var delegate : DisplayHelperDelegate
  public var ads : ReferenceArray
  
  public required init(ads : ReferenceArray, displayHelper: DisplayHelperDelegate){
    delegate = displayHelper
    self.ads = ads
  }
  
  public func didRecieveError(error: NSError) {
    
  }
  
  public func didRecieveResults(nativeAds: [NativeAd]) {
    // Dirty fix #3
    if((ads.collection.filter{$0 is NativeAd }).count > 0){
      return;
    }
    
    if(nativeAds.isEmpty) { return }
    
    self.ads.collection = nativeAds
    
    delegate.onUpdateCollection()
  }
  
  
  public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
  
}