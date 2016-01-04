//
//  AsynchronousRequest.swift
//  DiscoveryApp
//
//  Created by Carolina Barreiro Cancela on 28/05/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

public protocol NativeAdConnectionProtocol {
  func didRecieveError(error: NSError)
  func didRecieveResults(nativeAds: [NativeAd])
}

public struct NativeAd {
  
  public var campaignName        : String!
  public var campaignDescription : String!
  public var clickURL            : NSURL!
  public var campaignImage       : NSURL!
  
  public init?(adDictionary: NSDictionary){
    if let name = adDictionary["campaign_name"] as? String {
      self.campaignName = name
    } else {
      return nil
    }
    if let urlClick = adDictionary["click_url"] as? String, url = NSURL(string: urlClick) {
      self.clickURL = url
    } else {
      return nil
    }
    if let description = adDictionary["campaign_description"] as? String {
      self.campaignDescription = description
    }
    if let urlImage = adDictionary["campaign_image"] as? String, url = NSURL(string: urlImage) {
      self.campaignImage = url
    }
    
  }
}

public class NativeAdsRequest {
  
  public var delegate: NativeAdConnectionProtocol?
  
  public init() {
    self.delegate = nil
  }

  public init(delegate: NativeAdConnectionProtocol?) {
    self.delegate = delegate
  }
    
  public func retrieveAds(limit: UInt){
    let nativeAdURL = getNativeAdsURL(limit);
    print(nativeAdURL, terminator: "")
    if let url = NSURL(string: nativeAdURL) {
      let request = NSURLRequest(URL: url)
      NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
        if error != nil {
          self.delegate?.didRecieveError(error!)
        } else {
          if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
            var nativeAds: [NativeAd] = []
            for itemJson in json {
              if let itemAdDictionary = itemJson as? NSDictionary, ad = NativeAd(adDictionary: itemAdDictionary) {
                nativeAds.append(ad)
              }
            }
            if nativeAds.count > 0 {
              self.delegate?.didRecieveResults(nativeAds)
            } else {
              let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
              let error = NSError(domain: "NativeAd", code: -42, userInfo: userInfo)
              self.delegate?.didRecieveError(error)
            }
          }
        }
      }
    }
  }
  
  public func getNativeAdsURL(limit: UInt) -> String {
    var token = NSUserDefaults.standardUserDefaults().objectForKey(NativeAdsConstants.NativeAds.tokenAdKey) as? String
    if token == nil {
      token = "nativeAd\(NSDate().timeIntervalSince1970 * 100000)\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))"
      NSUserDefaults.standardUserDefaults().setObject(token, forKey: NativeAdsConstants.NativeAds.tokenAdKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
    return NativeAdsConstants.NativeAds.baseURL + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)&token=\(token!)&affiliate_id=\(NativeAdsConstants.NativeAds.affiliateId)"
  }
  
}