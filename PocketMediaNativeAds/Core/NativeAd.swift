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
    var url: NSURL!
    var width: UInt!
    var height: UInt!
}

/**
 NativeAd model object
 It contains the attributes received from the API, and allows to open the click URL
 */
public class NativeAd: NSObject {
    /// Name of the ad, the title to be displayed.
    private(set) public var campaignName: String!
    /// Long description of the ad, with a description
    private(set) public var campaignDescription: String!
    /// URL to be opened when the user interacts with the ad
    private(set) public var clickURL: NSURL!
    /// URL for the campaign icon
    private(set) public var campaignImage: NSURL!
    /// PocketMedia's Offer ID the ad is linked to
    private(set) var offerId: UInt?
    /// Ad Placement token the ad is linked to (via the ads request)
    private(set) var adPlacementToken: String!
    /// Images including hq_icon , banners and icon
    private(set) var images = [EImageType: SImage]()

    /**
     Fallible Constructor
     - adDictionary: JSON containing NativeAd Data
     */
    @objc
    public init(adDictionary: NSDictionary, adPlacementToken: String) throws {
        // Swift Requires all properties to be initialized before its possible to return nil
        super.init()

        self.adPlacementToken = adPlacementToken
        try parseName(adDictionary)
        try parseURL(adDictionary)
        try parseDescription(adDictionary)
        try parseIds(adDictionary)
        try parseMainImage(adDictionary)
        try parseImages(adDictionary)
    }

    private func parseImages(adDictionary: NSDictionary) throws {
        if let imageTypes = adDictionary["images"] as? [String: [String: String]] {
            for imageType in imageTypes {
                let image = imageType.1

                var width = UInt(0),
                    height = UInt(0),
                    url = NSURL()

                if let sWidth = image["width"] {
                    width = UInt(sWidth)!
                }

                if let sHeight = image["height"] {
                    height = UInt(sHeight)!
                }

                if let sUrl = image["url"] {
                    url = NSURL(string: sUrl)!
                }
                self.images[EImageType(string: imageType.0)!] = SImage(url: url, width: width, height: height)
            }
        } else {
            throw NativeAdsError.InvalidAdNoImages
        }
    }

    private func parseMainImage(adDictionary: NSDictionary) throws {
        if let urlImage = adDictionary["default_icon"] as? String, url = NSURL(string: urlImage) {
            self.campaignImage = url
        } else {
            if let urlImage = adDictionary["campaign_image"] as? String, url = NSURL(string: urlImage) {
                self.campaignImage = url
            } else {
                throw NativeAdsError.InvalidAdNoImage
            }
        }
    }

    private func parseIds(adDictionary: NSDictionary) throws {
        if let offerIdString = adDictionary["id"] as? String, let offerId = UInt(offerIdString) {
            self.offerId = offerId
        } else {
            throw NativeAdsError.InvalidAdNoId
        }
    }

    private func parseDescription(adDictionary: NSDictionary) throws {
        if let description = adDictionary["campaign_description"] as? String {
            self.campaignDescription = description
        } else {
            self.campaignDescription = ""
        }
    }

    private func parseURL(adDictionary: NSDictionary) throws {
        if let urlClick = adDictionary["click_url"] as? String, let url = NSURL(string: urlClick) {
            self.clickURL = url
        } else {
            throw NativeAdsError.InvalidAdNoClickUrl
        }
    }

    private func parseName(adDictionary: NSDictionary) throws {
        if let name = adDictionary["campaign_name"] as? String {
            self.campaignName = name
        } else {
            throw NativeAdsError.InvalidAdNoCampaign
        }
    }

    public override var description: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }
    public override var debugDescription: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }

    /**
     Opens Native Ad in an View handled by the NativeAdOpener
     - opener: NativeAdOpener instance handling the opening of the view where the NativeAd will be displayed.
     */
    @objc
    public func openAdUrl(opener: NativeAdOpenerDelegate) {
        opener.load(self)
    }
}
