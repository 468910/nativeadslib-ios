//
//  NativeAd.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//
import UIKit
/**
    - NativeAd Model Object
*/
public class NativeAd : NSObject{
    
    public var campaignName        : String!
    public var campaignDescription : String!
    // Initially it will be the original URL
    // In the different modifications / redirect follows it will be the target url
    // and the original value will be copied to originalClickUrl
    public var clickURL            : NSURL!
    public var campaignImage       : NSURL!
    
    public var originalClickUrl    : NSURL!
    public var destinationURL      : NSURL?
    
  
  
  
    /**
        -Fallible Constructor
        
        -Parameter adDictionary: JSON containing NativeAd Data
    */
    public init?(adDictionary: NSDictionary){
        // Swift Requires all properties to be initialized before its possible to return nil
        super.init()
      
      
        if let name = adDictionary["campaign_name"] as? String {
          self.campaignName = name
        }else{
          return nil
        }
        
        if let urlClick = adDictionary["click_url"] as? String, url = NSURL(string: urlClick) {
            self.clickURL = url
            self.originalClickUrl = self.clickURL
        }else{
            return nil
        }
        
        if let description = adDictionary["campaign_description"] as? String {
            self.campaignDescription = description
        }else{
            self.campaignDescription = ""
        }
        
        if let urlImage = adDictionary["default_icon"] as? String, url = NSURL(string: urlImage) {
            self.campaignImage = url
            
        }else{
            if let urlImage = adDictionary["campaign_image"] as? String, url = NSURL(string: urlImage) {
                self.campaignImage = url
            }else{
                return nil
            }
        }
        
    }
    
    override public var description: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
    override public var debugDescription: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
  
  
    /** 
      - Opens NativeAd in an closeable embedded webview.
    */
    public func openAdUrl(parentViewController: UIViewController){
        FullscreenBrowser(parentViewController: parentViewController).load(self)
    }
  
  
   /**
    - Opens Native Ad in an View handled by the NativeAdOpener 
      - paramater opener: NativeAdOpener handling the opening of the view where the NativeAd will be displayed.
   */
   public func openAdUrl(parentViewController: UIViewController, opener: NativeAdOpenerProtocol){
      opener.load(self)
    }
  
    /**
      - Opens NativeAd in foreground.
    */
    public func openAdUrlinForeground(){
      UIApplication.sharedApplication().openURL(self.clickURL)
    }
  
  
}
