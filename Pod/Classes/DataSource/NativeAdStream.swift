
//  NativeAdStream.swift
//  Pods
//
//  Created by apple on 25/05/16.
//
//

import Foundation

public class NativeAdStream : NSObject, NativeAdsConnectionDelegate {
	private var adFrequency: Int

    private var ads: [Int: NativeAd]
    public var datasource : DataSourceProtocol?
    public var tempAds : [NativeAd]
  
  public required init(controller : UITableViewController, adFrequency : Int){
        self.adFrequency = adFrequency
      self.ads = [Int:NativeAd]()
      self.tempAds = [NativeAd]()
    super.init()
    
        datasource = NativeAdTableViewDataSource(controller: controller, adStream: self)
    
	}
  
 
  
  public func didRecieveError(error: NSError) {
    
  }
  
  public func didRecieveResults(nativeAds: [NativeAd]) {
    
    if(nativeAds.isEmpty) {
      NSLog("No Ads Retrieved")
    }

    self.tempAds = nativeAds

     updateAdPositions()   
    
  }
 
  public func updateAdPositions(){
    var orginalCount = datasource!.numberOfElements()

    var adsInserted = 0
    for ad in tempAds {
      
       var index = adFrequency + (adFrequency * adsInserted) + adsInserted
      NSLog("The current index is %d", index)
      NSLog("Print dex is %d" ,  orginalCount + adsInserted)
      if(index > (orginalCount + adsInserted)){ break}
      ads[adFrequency + (adFrequency * adsInserted) + adsInserted] = ad
    }
     dump(ads) 
    datasource!.onUpdateDataSource()
     
      
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
    
    
    var adsInserted = position / adFrequency
    if(adsInserted > ads.count) {
      adsInserted = ads.count
    }
    
    return position - adsInserted
  }
  
  
  func getAdCount() -> Int {
    return ads.count
  }

  
  @objc public func requestAds(affiliateId: String , limit: UInt){
    NativeAdsRequest(adPlacementToken: affiliateId, delegate: self).retrieveAds(limit)
  }


}
