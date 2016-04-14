//
//  NativeAd.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//
import UIKit
/**
NativeAd model object
 
 
 It contains the attributes received from the API, and allows to open the click URL
*/
public class NativeAd : NSObject{

    /// Name of the ad, the title to be displayed.
    public var campaignName        : String!
    /// Long description of the ad, with a description
    public var campaignDescription : String!
    /// URL to be opened when the user interacts with the ad
    public var clickURL            : NSURL!
    /// URL for the campaign icon
    public var campaignImage       : NSURL!
    /// Preview url (itunes one)
    public var destinationURL      : NSURL?
    
    private var originalClickUrl    : NSURL!
    
  
  
  
    /**
        Fallible Constructor
        - adDictionary: JSON containing NativeAd Data
    */
    @objc
    public init?(adDictionary: NSDictionary){
        // Swift Requires all properties to be initialized before its possible to return nil
        super.init()
      
        if let name = adDictionary["campaign_name"] as? String {
          self.campaignName = name
        }else{
          print("Native Ad Fallible Constructor: No CampaignName found");
          return nil
        }
        
        if let urlClick = adDictionary["click_url"] as? String, url = NSURL(string: urlClick) {
            self.clickURL = url
            self.originalClickUrl = self.clickURL
        }else{
            print("Native Ad Fallible Constructor: No ClickUrl found");
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
               print("Native Ad Fallible Constructor: No Campaignimage found");
                return nil
            }
        }
        
    }
    
    override public var description: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
    override public var debugDescription: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
  
  
    /** 
      Opens NativeAd in an closeable embedded webview.
     - parentViewController: view controller where the webview will be attached to
    */
    @objc
    public func openAdUrl(parentViewController: UIViewController){
        FullscreenBrowser(parentViewController: parentViewController).load(self)
    }
  
  
   /**
    Opens Native Ad in an View handled by the NativeAdOpener
      - opener: NativeAdOpener instance handling the opening of the view where the NativeAd will be displayed.
   */
   @objc
   public func openAdUrl(parentViewController: UIViewController, opener: NativeAdOpenerDelegate){
      opener.load(self)
    }
  
  
  
    /**
      Opens NativeAd in foreground.
    */
    @objc
    public func openAdUrlInForeground(){
      print("FIREEEE")
      UIApplication.sharedApplication().openURL(self.clickURL)
    }
  
  
}
