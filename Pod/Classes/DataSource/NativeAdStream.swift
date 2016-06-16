
//  NativeAdStream.swift
//  Pods
//
//  Created by apple on 25/05/16.
//
//

import Foundation

public class NativeAdStream : NSObject, NativeAdsConnectionDelegate {
	private var adFrequency: Int
  
  
  // they are not called when variables are written to from an initializer or with a default value.
  public var firstAdPosition : Int {
    willSet {
      NSLog("First Ad Position Changed Preparing for Updating Ad Positions")
    }
    
    didSet {
      if firstAdPosition != oldValue{
        updateAdPositions()
      }
    }
  }

    private var ads: [Int: NativeAd]
    public var datasource : DataSourceProtocol?
    public var tempAds : [NativeAd]
  
  
  
  public  convenience init(controller: UIViewController, tableView: UITableView, adFrequency: Int){
    self.init(controller: controller, tableView: tableView, adFrequency: adFrequency, firstAdPosition: adFrequency)
  }
  
  public convenience init(controller: UIViewController, tableView: UITableView, adFrequency: Int, customXib: UINib){
    tableView.registerNib(customXib, forCellReuseIdentifier: "NativeAdViewCell")
    self.init(controller: controller, tableView: tableView, adFrequency: adFrequency)
  }
  
  public convenience init(controller: UIViewController, tableView: UITableView, adFrequency: Int, firstAdPosition: Int, customXib: UINib){
    tableView.registerNib(customXib, forCellReuseIdentifier: "NativeAdViewCell")
    self.init(controller: controller, tableView: tableView, adFrequency: adFrequency, firstAdPosition: firstAdPosition)
  }
  
  
  public required init(controller : UIViewController, tableView: UITableView, adFrequency : Int, firstAdPosition: Int){
    
    self.adFrequency = adFrequency
    self.firstAdPosition = firstAdPosition
    self.ads = [Int:NativeAd]()
    self.tempAds = [NativeAd]()
    super.init()
    
    datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: self)
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
      
      var index = firstAdPosition + (adFrequency * adsInserted) + adsInserted
      
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
