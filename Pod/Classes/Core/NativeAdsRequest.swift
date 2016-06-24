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
    /// Needed to identify the ad requests to the server
    public var adPlacementToken : String?
    /// To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    
    public init(adPlacementToken : String?, delegate: NativeAdsConnectionDelegate?) {
        super.init()
        self.adPlacementToken = adPlacementToken;
        self.delegate = delegate
    }
  
    /**
        Method used to retrieve native ads which are later accessed by using the delegate.
        - limit: Limit on how many native ads are to be retrieved.
    */
    @objc
    public func retrieveAds(limit: UInt){
        
        let nativeAdURL = getNativeAdsURL(self.adPlacementToken, limit: limit);
        NSLog("Invoking: %@", nativeAdURL)
        
        if let url = NSURL(string: nativeAdURL) {
            
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                
                if error != nil {
                    
                    self.delegate?.didRecieveError(error!)
                    
                } else {
                    var nativeAds: [NativeAd] = []
                    if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                        
                        json.filter({ ($0 as? NSDictionary) != nil}).forEach({ (element) -> () in
                            if let ad = NativeAd( adDictionary: element as! NSDictionary, adPlacementToken: self.adPlacementToken!){
                                nativeAds.append(ad)
                            }
                            
                        })
                        
                        if nativeAds.count > 0 {
                            self.delegate?.didReceiveResults(nativeAds)
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
    public func getNativeAdsURL(placementKey: String?, limit: UInt) -> String {
        let token = provideIdentifierForAdvertisingIfAvailable()
        
        let baseUrl = NativeAdsConstants.NativeAds.baseURL;
        //token
        var apiUrl = baseUrl + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)"
        apiUrl = apiUrl + "&token=" + token!
        apiUrl = apiUrl + "&placement_key=" + placementKey!
        
        if (!ASIdentifierManager.sharedManager().advertisingTrackingEnabled){
            apiUrl = apiUrl + "&optout=1"
        }
        
        return apiUrl
    }
    
    
    
}
