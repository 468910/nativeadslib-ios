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
  public var collection : ReferenceArray
  public var adMargin : Int? = -1
  public var adInjected : Int? = -1
  
  public required init(collection : ReferenceArray, displayHelper: DisplayHelperDelegate){
    delegate = displayHelper
    self.collection = collection
  }
  
  public func didRecieveError(error: NSError) {
    
  }
  
  public func didRecieveResults(nativeAds: [NativeAd]) {
    
    if((collection.collection.filter{$0 is NativeAd }).count > 0){
        return;
    }
    
    if(nativeAds.isEmpty || collection.collection.isEmpty) { return }
    
    var nativeAdCount = nativeAds.count
    
    let margin : Int = collection.collection.count / nativeAdCount
    
    adMargin = margin
    adInjected = nativeAdCount
    
    NSLog("Setted AdMargin\(margin) and NativeAdCount \(nativeAdCount)")
    var count : Int = 1
    
    nativeAds.forEach {
      // INjection
       collection.collection.insert($0, atIndex: margin * count)
      print("NativeAd Injected at Index: " + String(margin * count))
      
      
       count++
    }
    dump(collection.collection)
    print("Final Count is " + String(collection.collection.count))
    delegate.onUpdateCollection()
  }
  
  
  public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
  
}