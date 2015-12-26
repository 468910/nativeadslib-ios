//
//  AsynchronousRequest.swift
//  DiscoveryApp
//
//  Created by Carolina Barreiro Cancela on 28/05/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import Foundation

protocol NativeAdConnectionProtocol {
  func didRecieveError(error: NSError)
  func didRecieveResults(nativeAds: [NativeAd])
}

struct NativeAd {
  
  var campaignName        : String!
  var campaignDescription : String!
  var clickURL            : NSURL!
  var campaignImage       : NSURL!
  
  init?(adDictionary: NSDictionary){
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

class NativeAdsRequest {
  
  var delegate: NativeAdConnectionProtocol
  
  init(delegate: NativeAdConnectionProtocol) {
    self.delegate = delegate
  }
  func retrieveAds(limit: UInt){
    let nativeAdURL = getNativeAdsURL(limit);
    print(nativeAdURL, terminator: "")
    if let url = NSURL(string: nativeAdURL) {
      let request = NSURLRequest(URL: url)
      NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
        if error != nil {
          self.delegate.didRecieveError(error!)
        } else {
          if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
            var nativeAds: [NativeAd] = []
            for itemJson in json {
              if let itemAdDictionary = itemJson as? NSDictionary, ad = NativeAd(adDictionary: itemAdDictionary) {
                nativeAds.append(ad)
              }
            }
            if nativeAds.count > 0 {
              self.delegate.didRecieveResults(nativeAds)
            } else {
              let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
              let error = NSError(domain: "NativeAd", code: -42, userInfo: userInfo)
              self.delegate.didRecieveError(error)
            }
          }
        }
      }
    }
  }
  
  func getNativeAdsURL(limit: UInt) -> String {
    var token = NSUserDefaults.standardUserDefaults().objectForKey(Constants.NativeAds.tokenAdKey) as? String
    if token == nil {
      token = "nativeAd\(NSDate().timeIntervalSince1970 * 100000)\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))\(arc4random_uniform(9999999))"
      NSUserDefaults.standardUserDefaults().setObject(token, forKey: Constants.NativeAds.tokenAdKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
    return Constants.NativeAds.baseURL + "&os=ios&limit=\(limit)&version=\(Constants.Device.iosVersion)&model=\(Constants.Device.model)&token=\(token!)&affiliate_id=\(Constants.NativeAds.affiliateId)"
  }
  
}