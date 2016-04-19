//
//  AsynchronousRequest.swift
//  DiscoveryApp
//
//  Created by Carolina Barreiro Cancela on 28/05/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import AdSupport

/**
    Object which is used to make a NativeAdsRequest has to be used in combination with the NativeAdsConnectionDelegate
*/
public class NativeAdsRequest : NSObject, NSURLConnectionDelegate, UIWebViewDelegate {
    
    /// Object to notify about the updates related with the ad request
    public var delegate: NativeAdsConnectionDelegate?
    /// Needed to "sign" the ad requests to the server
    public var affiliateId : String?
    /// To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    /// To allow testing with links without impacting impressions and clicks
    public var betaModeEnabled : Bool = false
      private var isDling : Bool = false
  
  
    public init(affiliateId : String?, delegate: NativeAdsConnectionDelegate?) {
        super.init()
        self.affiliateId = affiliateId;
        self.delegate = delegate
    }
  
    /**
        Method used to retrieve native ads which are later accessed by using the delegate.
        - limit: Limit on how many native ads are to be retrieved.
    */
    @objc
    public func retrieveAds(limit: UInt){
      
      if(isDling){
        NSLog("Aborting call - already downloading")
        self.delegate?.didRecieveError(NSError(domain: "somedomain", code: 123, userInfo: [:]))
      }
      
        let nativeAdURL = getNativeAdsURL(self.affiliateId, limit: limit);
        NSLog("Invoking: %@", nativeAdURL)
      isDling = true
      
      
        if let url = NSURL(string: nativeAdURL) {
            
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
              
                self.isDling = false
              
                if error != nil {
                    
                    self.delegate?.didRecieveError(error!)
                    
                } else {
                    var nativeAds: [NativeAd] = []
                    if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                        
                        json.filter({ ($0 as? NSDictionary) != nil}).forEach({ (element) -> () in
                            if let ad = NativeAd( adDictionary: element as! NSDictionary){
                                nativeAds.append(ad)
                            }
                            
                        })
                        
                        if nativeAds.count > 0 {
                            self.delegate?.didRecieveResults(nativeAds)
                        } else {
                            let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
                            let error = NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: userInfo)
                            self.delegate?.didRecieveError(error)
                        }
                    }
                }
            }
        }
    }
    
    func provideIdentifierForAdvertisingIfAvailable() -> String? {
        return ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString
    }
    
    /**
    Returns the API URL to invoke to retrieve ads
    */
    public func getNativeAdsURL(placementToken: String?, limit: UInt) -> String {
        let token = provideIdentifierForAdvertisingIfAvailable()
        
        let baseUrl = betaModeEnabled ? NativeAdsConstants.NativeAds.baseURLBeta : NativeAdsConstants.NativeAds.baseURL;
        //token
        var apiUrl = baseUrl + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)"
        apiUrl = apiUrl + "&token=" + token!
        apiUrl = apiUrl + "&placement_key=" + placementToken!
        
        if (!ASIdentifierManager.sharedManager().advertisingTrackingEnabled){
            apiUrl = apiUrl + "&optout=1"
        }
        
        return apiUrl
    }
    
    
    
}
