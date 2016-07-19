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
    /// To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    /// Parameters private setter
    private(set) var parameters : [String : String] = [
    "token" : (ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString)!,
    "os" : "ios",
    "version" : "\(NativeAdsConstants.Device.iosVersion)",
    "model" : NativeAdsConstants.Device.model,
   ]
  
   public enum imageType : String {
    case all_images = ""
    case icon = "icon"
    case hq_icon = "hq_icon"
    case banner = "banner"
    case bigImages = "banner,hq_icon"
    case bannerAndIcons = "banner,icon"
   }
  
  public var imageFilter : imageType = .all_images {
    willSet(newImageType){
      NSLog("NativeAdsRequest", "Changing imagefilter")
    }
    didSet {
      if imageFilter == imageType.all_images {
        parameters.removeValueForKey("image_filter")
      }else{
      parameters["image_type"] = imageFilter.rawValue
      }
    }
  }
  
  
    public init(adPlacementToken : String?, delegate: NativeAdsConnectionDelegate?) {
        super.init()
      
        parameters["placement_key"]  = adPlacementToken!
      
        if (!ASIdentifierManager.sharedManager().advertisingTrackingEnabled){
          parameters["optout"] = "1"
        }
      
      
        self.delegate = delegate
   }
  
    /**
     Method used to retrieve native ads which are later accessed by using the delegate.
     - limit: Limit on how many native ads are to be retrieved.
     */
    @objc
    public func retrieveAds(limit: UInt){
        
      
      if let url = NSURL.initWithParameters(self.parameters, path: NativeAdsConstants.NativeAds.baseUrl.rawValue){
            var request = NSMutableURLRequest.init(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                
                if error != nil {
                    
                    self.delegate?.didRecieveError(error!)
                    
                } else {
                    var nativeAds: [NativeAd] = []
                    if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                        
                        json.filter({ ($0 as? NSDictionary) != nil}).forEach({ (element) -> () in
                            if let ad = NativeAd( adDictionary: element as! NSDictionary, adPlacementToken: self.parameters["placement_key"]!){
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
    
}




extension NSURL {
  
  static func initWithParameters(parameters: Dictionary<String, String> , path: String) -> NSURL? {
    let parameterArray = parameters.map { (key, value) -> String in
      return "\(key)=\(value.stringByAddingPercentEscapesForQueryValue()!)"
    }
    var string = "\(path)&\(parameterArray.joinWithSeparator("&"))"
    print(string)
    return NSURL(string: string)
  }
  
  
}


extension String {
  
  /// Percent escape value to be added to a URL query value as specified in RFC 3986
  ///
  /// This percent-escapes all characters except the alphanumeric character set and "-", ".", "_", and "~".
  ///
  /// http://www.ietf.org/rfc/rfc3986.txt
  ///
  /// - returns:   Return precent escaped string.
  
  func stringByAddingPercentEscapesForQueryValue() -> String? {
    let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
    characterSet.addCharactersInString("-._~")
    return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
  }
}