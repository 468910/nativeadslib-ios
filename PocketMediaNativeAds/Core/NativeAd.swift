//
//  NativeAd.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//
import UIKit

/**
 Image model object
 It contains the attributes that every image in an ad has.
 */
public struct SImage {
    var url: URL!
    var width: UInt!
    var height: UInt!
}

/**
 NativeAd model object
 It contains the attributes received from the API, and allows to open the click URL
 */
@objc
open class NativeAd: NSObject {
    /// Name of the ad, the title to be displayed.
    @objc
    fileprivate(set) open var campaignName: String!
    /// Long description of the ad, with a description
    @objc
    fileprivate(set) open var campaignDescription: String!
    /// Action text (like "Install", "Read more" and so on)
    @objc
    fileprivate(set) public var callToActionText: String! = ""
    /// Boolean to indicate if the ad should be opened in the browser or use the internal one
    @objc
    fileprivate(set) public var shouldBeManagedExternally: Bool = false
    /// URL to be opened when the user interacts with the ad
    @objc
    fileprivate(set) open var clickURL: URL!
    /// Preview URL. Might be empty.
    @objc
    fileprivate(set) public var previewURL: NSURL!
    /// URL for the campaign icon
    @objc
    fileprivate(set) open var campaignImage: URL!
    /// PocketMedia's Offer ID the ad is linked to
    fileprivate(set) var offerId: UInt?
    /// Ad Placement token the ad is linked to (via the ads request)
    @objc
    fileprivate(set) var adPlacementToken: String!
    /// Images including hq_icon , banners and icon
    fileprivate(set) var images = [EImageType: SImage]()

    /**
     Fallible Constructor
     - adDictionary: JSON containing NativeAd Data
     */
    @objc
    public init(adDictionary: Dictionary<String, Any>, adPlacementToken: String) throws {
        // Swift Requires all properties to be initialized before its possible to return nil
        super.init()

        self.adPlacementToken = adPlacementToken
        try parseName(adDictionary)
        try parseURL(adDictionary)
        try parseDescription(adDictionary)
        try parseIds(adDictionary)
        try parseMainImage(adDictionary)
        try parseImages(adDictionary)
        try parseCallToAction(adDictionary as NSDictionary)
        try parseShouldBeManagedExternally(adDictionary as NSDictionary)
        try parsePreviewURL(adDictionary as NSDictionary)
    }

    fileprivate func parseImages(_ adDictionary: Dictionary<String, Any>) throws {
        if let imageTypes = adDictionary["images"] as? [String: [String: String]] {
            for imageType in imageTypes {
                let image = imageType.1

                var width = UInt(0),
                    height = UInt(0),
                    url = URL(string: "http://pocketmedia.mobi/")

                if let sWidth = image["width"] {
                    width = UInt(sWidth)!
                }

                if let sHeight = image["height"] {
                    height = UInt(sHeight)!
                }

                if let sUrl = image["url"] {
                    url = URL(string: sUrl)!.getSecureUrl()
                }
                self.images[EImageType(rawValue: imageType.0)!] = SImage(url: url, width: width, height: height)
            }
        } else {
            throw NativeAdsError.invalidAdNoImages
        }
    }

    fileprivate func parseMainImage(_ adDictionary: Dictionary<String, Any>) throws {
        if let urlImage = adDictionary["default_icon"] as? String, let url = URL(string: urlImage) {
            self.campaignImage = url
        } else {
            if let urlImage = adDictionary["campaign_image"] as? String, let url = URL(string: urlImage) {
                self.campaignImage = url.getSecureUrl()
            } else {
                throw NativeAdsError.invalidAdNoImage
            }
        }
    }

    fileprivate func parseIds(_ adDictionary: Dictionary<String, Any>) throws {
        if let offerIdString = adDictionary["id"] as? String, let offerId = UInt(offerIdString) {
            self.offerId = offerId
        } else {
            throw NativeAdsError.invalidAdNoId
        }
    }

    fileprivate func parseDescription(_ adDictionary: Dictionary<String, Any>) throws {
        if let description = adDictionary["campaign_description"] as? String {
            self.campaignDescription = description
        } else {
            self.campaignDescription = ""
        }
    }

    fileprivate func parseURL(_ adDictionary: Dictionary<String, Any>) throws {
        if let urlClick = adDictionary["click_url"] as? String, let url = URL(string: urlClick) {
            self.clickURL = url.getSecureUrl()
        } else {
            throw NativeAdsError.invalidAdNoClickUrl
        }
    }

    fileprivate func parseName(_ adDictionary: Dictionary<String, Any>) throws {
        if let name = adDictionary["campaign_name"] as? String {
            self.campaignName = name
        } else {
            throw NativeAdsError.invalidAdNoCampaign
        }
    }
    
    private func parseCallToAction(_ adDictionary: NSDictionary) throws {
        if let callToActionText = adDictionary["action_text"] as? String {
            self.callToActionText = callToActionText
        } else {
            self.callToActionText = ""
        }
    }
    
    private func parseShouldBeManagedExternally(_ adDictionary: NSDictionary) throws {
        if let open_in_browser = adDictionary["open_in_browser"] as? Bool {
            self.shouldBeManagedExternally = open_in_browser
        } else {
            self.shouldBeManagedExternally = true
        }
    }
    
    private func parsePreviewURL(_ adDictionary: NSDictionary) throws {
        if let previewURL = adDictionary["app_store_url"] as? String, let url = NSURL(string: previewURL) {
            self.previewURL = url
        }
    }

    open override var description: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }
    open override var debugDescription: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }

    @objc
    public func bannerUrl() -> URL? {
        var url: URL?
        if images[EImageType.hqIcon] != nil {
            url = images[EImageType.banner]?.url
        }
        return url
    }
    
    @objc
    public func hqIconUrl() -> URL? {
        var url: URL?
        if images[EImageType.hqIcon] != nil {
            url = images[EImageType.hqIcon]?.url
        }
        return url
    }
    
    @objc
    public func iconUrl() -> URL? {
        var url: URL?
        if images[EImageType.icon] != nil {
            url = images[EImageType.icon]?.url
        }
        return url
    }
    
    /**
     Opens Native Ad in an View handled by the NativeAdOpener
     - opener: NativeAdOpener instance handling the opening of the view where the NativeAd will be displayed.
     */
    @objc
    open func openAdUrl(_ opener: NativeAdOpenerDelegate) {
        opener.load(self)
    }
    

}

fileprivate extension URL
{
    func getSecureUrl() -> URL{
        let secureString = self.absoluteString.replacingOccurrences(of: "http", with: "https")
        if let secureUrl = URL(string: secureString){
            return secureUrl
        }else{
            return self
        }
    }
}
