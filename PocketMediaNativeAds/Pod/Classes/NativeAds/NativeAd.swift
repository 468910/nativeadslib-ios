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
    
    public init?(adDictionary: NSDictionary){
        
        if let name = adDictionary["campaign_name"] as? String {
            self.campaignName = name
        }
        if let urlClick = adDictionary["click_url"] as? String, url = NSURL(string: urlClick) {
            self.clickURL = url
            self.originalClickUrl = self.clickURL
        }
        if let description = adDictionary["campaign_description"] as? String {
            self.campaignDescription = description
        }
        if let urlImage = adDictionary["campaign_image"] as? String, url = NSURL(string: urlImage) {
            self.campaignImage = url
        }
    }
    
    override public var description: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
    override public var debugDescription: String {return "NativeAd.\(campaignName): \(clickURL.absoluteURL)"}
    
    public func openCampaign(){
        UIApplication.sharedApplication().openURL(clickURL)
    }
}
