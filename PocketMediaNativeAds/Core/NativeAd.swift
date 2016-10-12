//
//  NativeAd.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 14/01/16.
//
//
import UIKit

public struct sImage {
    var url: URL!
    var width: UInt!
    var height: UInt!
}

/**
 NativeAd model object
 It contains the attributes received from the API, and allows to open the click URL
 */
open class NativeAd: NSObject {
    /// Name of the ad, the title to be displayed.
	fileprivate(set) open var campaignName: String!
	/// Long description of the ad, with a description
	fileprivate(set) open var campaignDescription: String!
	/// URL to be opened when the user interacts with the ad
	fileprivate(set) open var clickURL: URL!
	/// URL for the campaign icon
	fileprivate(set) open var campaignImage: URL!
	/// PocketMedia's Offer ID the ad is linked to
	fileprivate(set) var offerId: UInt?
	/// Ad Placement token the ad is linked to (via the ads request)
	fileprivate(set) var adPlacementToken: String!
	/// Images including hq_icon , banners and icon
    fileprivate(set) var images = [EImageType: sImage]()

	/**
     Fallible Constructor
     - adDictionary: JSON containing NativeAd Data
     */
	@objc
	public init(adDictionary: NSDictionary, adPlacementToken: String) throws {
		// Swift Requires all properties to be initialized before its possible to return nil
		super.init()

		self.adPlacementToken = adPlacementToken

		if let name = adDictionary["campaign_name"] as? String {
			self.campaignName = name
		} else {
			throw NativeAdsError.invalidAdNoCampaign
		}

		if let urlClick = adDictionary["click_url"] as? String, let url = URL(string: urlClick) {
			self.clickURL = url
		} else {
			throw NativeAdsError.invalidAdNoClickUrl
		}

		if let description = adDictionary["campaign_description"] as? String {
			self.campaignDescription = description
		} else {
			self.campaignDescription = ""
		}

		if let offerIdString = adDictionary["id"] as? String, let offerId = UInt(offerIdString) {
			self.offerId = offerId
		} else {
			throw NativeAdsError.invalidAdNoId
		}

		if let urlImage = adDictionary["default_icon"] as? String, let url = URL(string: urlImage) {
			self.campaignImage = url
		} else {
			if let urlImage = adDictionary["campaign_image"] as? String, let url = URL(string: urlImage) {
				self.campaignImage = url
			} else {
				throw NativeAdsError.invalidAdNoImage
			}
		}

        if let imageTypes = adDictionary["images"] as? [String: [String: String]] {
            for imageType in imageTypes {
                let image = imageType.1

                var width = UInt(0),
                    height = UInt(0),
                    url = URL(string: "")

                if let sWidth = image["width"] {
                    width = UInt(sWidth)!
                }

                if let sHeight = image["height"] {
                    height = UInt(sHeight)!
                }

                if let sUrl = image["url"] {
                    url = URL(string: sUrl)!
                }
                self.images[EImageType(rawValue: imageType.0)!] = sImage(url: url, width: width, height: height)
            }
		} else {
			throw NativeAdsError.invalidAdNoImages
		}
	}

	override open var description: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }
	override open var debugDescription: String { return "NativeAd.\(campaignName): \(clickURL.absoluteURL)" }

	/**
     Opens Native Ad in an View handled by the NativeAdOpener
     - opener: NativeAdOpener instance handling the opening of the view where the NativeAd will be displayed.
     */
	@objc
	open func openAdUrl(_ opener: NativeAdOpenerProtocol) {
		opener.load(self)
	}

}
