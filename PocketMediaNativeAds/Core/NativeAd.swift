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
 Model class. It contains all the attributes received from the API, and allows to open the click URL with a specific opener.
 */
@objc
open class NativeAd: NSObject {
    /// Name of the ad, the title to be displayed.
    @objc
    fileprivate(set) open var campaignName: String!
    /// Long description of the ad, with a description
    @objc
    fileprivate(set) open var campaignDescription: String!
    /// Action text (Values like "Install", "Read more" and so on)
    @objc
    fileprivate(set) public var callToActionText: String = ""
    /// Boolean to indicate if the ad should be opened in the browser or use the internal one
    @objc
    fileprivate(set) public var shouldBeManagedExternally: Bool = false
    /// URL to be opened when the user interacts with the ad
    @objc
    fileprivate(set) open var clickURL: URL!
    /// Preview URL. Might be empty.
    @objc
    fileprivate(set) public var previewURL: URL?
    /// URL for the campaign icon
    @objc
    fileprivate(set) open var campaignImage: URL!
    /// PocketMedia's Offer ID the ad is linked to
    fileprivate(set) var offerId: UInt!
    /// Ad Placement token the ad is linked to (via the ads request)
    @objc
    fileprivate(set) var adPlacementToken: String!
    /// Images including hq_icon , banners and icon
    fileprivate(set) var images = [EImageType: SImage]()

    /// Description used. When referring to this ad instance.
    open override var description: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }
    /// Description used. When referring to this ad instance in a debug fashion.
    open override var debugDescription: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }

    /**
     Fallible Constructor
     - parameter adDictionary: JSON object containing NativeAd Data
     - paramter adPlacementToken: The ad placement token.
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

    /**
     Goes through the ad dictionary and parses it for images. Populates self.images
     - parameter adDictionary: JSON object containing NativeAd Data
     - Throws: `NativeAdsError.invalidAdNoImages` if the `adDictionary` parameter
     doesn't contain images.
     */
    private func parseImages(_ adDictionary: Dictionary<String, Any>) throws {
        if let imageTypes = adDictionary["images"] as? [String: [String: String]] {
            for imageType in imageTypes {
                let image = imageType.1

                var width = UInt(0),
                    height = UInt(0),
                    url = URL(string: "https://pocketmedia.mobi/")

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

    /**
     Goes through the ad dictionary and parses it for the main image either `default_icon` or `campaign_image`. Defines self.campaignImage
     - parameter adDictionary: JSON object containing NativeAd Data
     - Throws: `NativeAdsError.invalidAdNoImage` if the `adDictionary` parameter
     doesn't contain default_icon and campaign_image.
     */
    private func parseMainImage(_ adDictionary: Dictionary<String, Any>) throws {
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

    /**
     Goes through the ad dictionary and parses it for the offer id. Defines self.offerId
     - parameter adDictionary: JSON object containing NativeAd Data
     - Throws: `NativeAdsError.invalidAdNoId` if the `adDictionary` parameter
     doesn't contain an id.
     */
    private func parseIds(_ adDictionary: Dictionary<String, Any>) throws {
        if let offerIdString = adDictionary["id"] as? String, let offerId = UInt(offerIdString) {
            self.offerId = offerId
        } else {
            throw NativeAdsError.invalidAdNoId
        }
    }

    /**
     Goes through the ad dictionary and parses it for the description of this offer. Defines self.campaignDescription. (default empty)
     - parameter adDictionary: JSON object containing NativeAd Data.
     */
    private func parseDescription(_ adDictionary: Dictionary<String, Any>) {
        if let description = adDictionary["campaign_description"] as? String {
            self.campaignDescription = description
        } else {
            self.campaignDescription = ""
        }
    }

    /**
     Goes through the ad dictionary and parses it for the url of this offer. Defines self.clickURL
     - parameter adDictionary: JSON object containing NativeAd Data.
     - Throws: `NativeAdsError.invalidAdNoClickUrl` if the `adDictionary` parameter
     doesn't contain an url.
     */
    private func parseURL(_ adDictionary: Dictionary<String, Any>) throws {
        if let urlClick = adDictionary["click_url"] as? String, let url = URL(string: urlClick) {
            self.clickURL = url.getSecureUrl()
        } else {
            throw NativeAdsError.invalidAdNoClickUrl
        }
    }

    /**
     Goes through the ad dictionary and parses it for the name of this offer. Defines self.campaignName
     - parameter adDictionary: JSON object containing NativeAd Data.
     - Throws: `NativeAdsError.invalidAdNoCampaign` if the `adDictionary` parameter
     doesn't contain a name.
     */
    private func parseName(_ adDictionary: Dictionary<String, Any>) throws {
        if let name = adDictionary["campaign_name"] as? String {
            self.campaignName = name
        } else {
            throw NativeAdsError.invalidAdNoCampaign
        }
    }

    /**
     Goes through the ad dictionary and parses it for the call to action of this offer (The button). Defines self.callToActionText (default empty)
     - parameter adDictionary: JSON object containing NativeAd Data.
     */
    private func parseCallToAction(_ adDictionary: NSDictionary) {
        if let callToActionText = adDictionary["action_text"] as? String {
            self.callToActionText = callToActionText
        } else {
            self.callToActionText = ""
        }
    }

    /**
     Goes through the ad dictionary and parses it for the boolean if this ad should be externally managed. Defines self.shouldBeManagedExternally (default false)
     - parameter adDictionary: JSON object containing NativeAd Data.
     */
    private func parseShouldBeManagedExternally(_ adDictionary: NSDictionary) {
        if let open_in_browser = adDictionary["open_in_browser"] as? Bool {
            self.shouldBeManagedExternally = open_in_browser
        } else {
            self.shouldBeManagedExternally = false
        }
    }

    /**
     Goes through the ad dictionary and parses it for the app store url. Defines self.previewURL (default empty)
     - parameter adDictionary: JSON object containing NativeAd Data.
     */
    private func parsePreviewURL(_ adDictionary: NSDictionary) throws {
        if let previewURL = adDictionary["app_store_url"] as? String, let url = URL(string: previewURL) {
            self.previewURL = url
        }
    }

    /**
     Get banner url
     - returns: URL instance of the banner.
     */
    @objc
    open func bannerUrl() -> URL? {
        var url: URL?
        if images[EImageType.hqIcon] != nil {
            url = images[EImageType.banner]?.url
        }
        return url
    }

    /**
     Get hq icon url
     - returns: URL instance of the hq icon.
     */
    @objc
    open func hqIconUrl() -> URL? {
        var url: URL?
        if images[EImageType.hqIcon] != nil {
            url = images[EImageType.hqIcon]?.url
        }
        return url
    }

    /**
     Get icon url
     - returns: URL instance of the icon.
     */
    @objc
    open func iconUrl() -> URL? {
        var url: URL?
        if images[EImageType.icon] != nil {
            url = images[EImageType.icon]?.url
        }
        return url
    }

    /**
     Opens this ad in a new view handled by an instance that conforms to the NativeAdOpenerDelegate protocol.
     - parameter opener: NativeAdOpener instance handling the opening of the view where the NativeAd will be displayed.
     */
    @objc
    open func openAdUrl(_ opener: NativeAdOpenerDelegate) {
        opener.load(self)
    }
}

/**
 This extension makes sure we'll use the HTTPS version of the url.
 */
fileprivate extension URL {
    /**
     Returns a URL instance that ALWAYS uses the HTTPS scheme.
     */
    func getSecureUrl() -> URL {
        if self.scheme != "https" {
            let secureString = self.absoluteString.replacingOccurrences(of: "http", with: "https")
            if let secureUrl = URL(string: secureString) {
                return secureUrl
            }
        }
        return self
    }
}
