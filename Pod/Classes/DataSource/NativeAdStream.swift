
//  NativeAdStream.swift
//  Pods
//
//  Created by apple on 25/05/16.
//
//

import Foundation

public class NativeAdStream : NSObject, NativeAdsConnectionDelegate {
	private var adFrequency: Int?
  
  
  // they are not called when variables are written to from an initializer or with a default value.
  public var firstAdPosition : Int? {
    willSet {
      NSLog("First Ad Position Changed Preparing for Updating Ad Positions")
    }
    
    didSet {
      if firstAdPosition != oldValue{
        updateAdPositions()
      }
    }
  }
  
  
    private var adsPositionGivenByUser : [Int]?
    private var ads: [Int: NativeAd]
    public var datasource : DataSourceProtocol?
    public var tempAds : [NativeAd]
  
  
  
  public  convenience init(controller: UIViewController, mainView: UIView, adFrequency: Int){
    self.init(controller: controller, mainView: mainView, adFrequency: adFrequency, firstAdPosition: adFrequency)
  }
  
  
  public convenience init(controller: UIViewController, mainView: UIView, adFrequency: Int, firstAdPosition: Int, customXib: UINib){
    
    self.init(controller: controller, mainView: mainView, customXib: customXib)
    self.firstAdPosition = firstAdPosition
    self.adFrequency = adFrequency
  }
  
  public convenience init(controller: UIViewController, mainView: UIView, adsPositions: [Int], customXib: UINib){
    
    self.init(controller: controller, mainView: mainView, customXib: customXib)
    self.adsPositionGivenByUser = Array(Set(adsPositions)).sort{$0 < $1}
  }
  
  public convenience init(controller: UIViewController, mainView: UIView, customXib: UINib){
    switch mainView {
    case let tableView as UITableView:
      tableView.registerNib(customXib, forCellReuseIdentifier: "NativeAdTableViewCell")
       self.init(controller: controller, mainView: tableView)
      break
    case let collectionView as UICollectionView:
    self.init(controller: controller, mainView: collectionView)
      break
    default:
      self.init(controller: controller, mainView: mainView)
      break
    }
    
  
  }
  
  public convenience init(controller: UIViewController, mainView: UIView, adsPositions: [Int]){
    self.init(controller: controller, mainView: mainView)
    self.adsPositionGivenByUser = Array(Set(adsPositions)).sort{$0 < $1}
  }
  
   public convenience init(controller : UIViewController, mainView: UIView, adFrequency : Int, firstAdPosition: Int){
    self.init(controller: controller, mainView: mainView)
    self.adFrequency = adFrequency
    self.firstAdPosition = firstAdPosition
  }
  
  public required init(controller : UIViewController, mainView: UIView){
    
    self.ads = [Int:NativeAd]()
    self.tempAds = [NativeAd]()
    super.init()
    
    switch mainView {
    case let tableView as UITableView:
         datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: self)
      break
    case let collectionView as UICollectionView:
         datasource = NativeAdCollectionViewDataSource(controller: controller, collectionView: collectionView, adStream: self)
    default:
      break
    }
   
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
   
    if(adsPositionGivenByUser == nil){
      updateAdPositionsWithAdFrequency()
    }else {
      updateAdPositionsWithPositionsGivenByUser()
    }
    
    datasource!.onUpdateDataSource()
    
  }
  
  private func updateAdPositionsWithPositionsGivenByUser() {
    
       var orginalCount = datasource!.numberOfElements()
    
       var adsInserted = 0
    for ad in tempAds {
      if(adsInserted >= adsPositionGivenByUser!.count){
        break
      }
      
      if(adsPositionGivenByUser![adsInserted] >= orginalCount){
        break
      }
      ads[adsPositionGivenByUser![adsInserted]] = ad
      adsInserted += 1
    }
    
    
  }
  private func updateAdPositionsWithAdFrequency() {
    var orginalCount = datasource!.numberOfElements()
    
    var adsInserted = 0
    for ad in tempAds {
      
      var index = (firstAdPosition! - 1) + (adFrequency! * adsInserted)
      
      NSLog("The current index is %d", index)
      NSLog("Print dex is %d" ,  orginalCount + adsInserted)
      if(index > (orginalCount + adsInserted)){ break}
      ads[index] = ad
      adsInserted += 1
    }
    var tempads = ads
    print("yay")
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
    
    if(adsPositionGivenByUser != nil){
      var adsInserted = 0
      for pos in adsPositionGivenByUser! {
        if(pos < position){
          adsInserted += 1
          
        }
      }
      return position - adsInserted
    }
    
    
    if(position < adFrequency) {
      return position
    }
    
    
    var adsInserted = position / adFrequency!
    if(adsInserted > ads.count) {
      adsInserted = ads.count
    }
   
    var tempads = ads
    var temp = position - adsInserted
    return position - adsInserted
  }
  
  
  func getAdCount() -> Int {
    return ads.count
  }

  
  @objc public func requestAds(affiliateId: String , limit: UInt){
    NativeAdsRequest(adPlacementToken: affiliateId, delegate: self).retrieveAds(limit)
  }


}
