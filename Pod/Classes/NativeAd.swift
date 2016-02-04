//
//  NativeAd.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//


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
    
    //public var webViewDelegate     : NativeAdsWebviewDelegate?
    public var webviewController   : FullscreenBrowser?
    
    
    
    // Fallible Constructor
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
    
    public func openCampaign(inTheForeground : Bool = false, parentViewController : UIViewController){
        if (inTheForeground){
            UIApplication.sharedApplication().openURL(clickURL)
        }else{
            self.openCampaignWithWebview(parentViewController)
        }
    }
    
    private func openCampaignWithWebview(parentViewController : UIViewController){
        NSLog("Pushing fullscreen webview, opening: \(clickURL.absoluteString)")
        
        if self.webviewController == nil{
            self.webviewController = FullscreenBrowser(parentViewController: parentViewController, adUnit: self)
        }
        
        self.webviewController?.load(self)
        
    }
}
