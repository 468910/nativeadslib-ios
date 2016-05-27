//
//  NativeAdStream.swift
//  Pods
//
//  Created by apple on 25/05/16.
//
//

import Foundation

public class NativeAdStream : NSObject, NativeAdsConnectionDelegate {
	private var adFrequency: Int
    private var delegate : DisplayHelperDelegate
    private var ads: [Int: NativeAd]
    public var datasource : NativeAdTableViewDataSource
  
  public required init(adFrequency : Int, datasource: NativeAdTableViewDataSource, delegate: DisplayHelperDelegate){
        self.adFrequency = adFrequency
        self.datasource = datasource
        self.ads = [Int:NativeAd]()
        self.delegate = delegate
	}
  
 
  
  public func didRecieveError(error: NSError) {
    
  }
  
  public func didRecieveResults(nativeAds: [NativeAd]) {
    NSLog("Monkeys")
    
    if(nativeAds.isEmpty) {
      NSLog("No Ads Retrieved")
    }
    var orginalCount = datasource.getOriginalCollectionCount()
    var adsInserted = 0
    for ad in nativeAds {
       var index = adFrequency + (adFrequency * adsInserted) + adsInserted
      if(index > orginalCount){ break}
      ads[adFrequency + (adFrequency * adsInserted) + adsInserted] = ad
     
      
      NSLog("This is inserting %d", index)
      adsInserted += 1
    }
    
    
    delegate.onUpdateCollection()
  }
  
  
  public func didUpdateNativeAd(adUnit: NativeAd) {
    
  }
 


  func isAdAtposition(position : Int)->NativeAd? {
      if let val = ads[position] {
        return val
      }else {
        return nil
      }
	}
  
  
  func normalize(position : Int)->Int {
    if(ads.isEmpty) {
      return position
    }
    
    if(position < adFrequency) {
      return position
    }
    
  
    if((position / adFrequency) > 1){
      if(position < ((adFrequency * (position / adFrequency)) + position / adFrequency)){
        return position - ((position / adFrequency) - 1)
      }
    }
    
    return position - (position / adFrequency)
  }
  
  
  func getAdCount() -> Int {
    return ads.count
  }



}