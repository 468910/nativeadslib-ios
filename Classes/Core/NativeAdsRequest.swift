//
//  AsynchronousRequest.swift
//  DiscoveryApp
//
//  Created by Carolina Barreiro Cancela on 28/05/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import AdSupport

public enum EImageType: String {
	case allImages = ""
	case icon = "icon"
	case hqIcon = "hq_icon"
	case banner = "banner"
	case bigImages = "banner,hq_icon"
	case bannerAndIcons = "banner,icon"
}

/**
 Object which is used to make a NativeAdsRequest has to be used in combination with the NativeAdsConnectionDelegate
 */
public class NativeAdsRequest: NSObject, NSURLConnectionDelegate, UIWebViewDelegate {

	/// Object to notify about the updates related with the ad request
	public var delegate: NativeAdsConnectionDelegate?
	/// Needed to identify the ad requests to the server
	public var adPlacementToken: String?
	/// Check whether advertising tracking is limited
	public var advertisingTrackingEnabled: Bool? = false
	/// URL session used to do network requests.
	public var session: URLSessionProtocol? = nil

	public init(adPlacementToken: String?,
		delegate: NativeAdsConnectionDelegate?,
		advertisingTrackingEnabled: Bool = ASIdentifierManager.sharedManager().advertisingTrackingEnabled,
		session: URLSessionProtocol = NSURLSession.sharedSession()
	) {
		super.init()
		self.adPlacementToken = adPlacementToken;
		self.delegate = delegate
		self.advertisingTrackingEnabled = advertisingTrackingEnabled
		self.session = session
	}

	/**
     Method used to retrieve native ads which are later accessed by using the delegate.
     - limit: Limit on how many native ads are to be retrieved.
     -  imageType: Image Type is used to specify what kind of image type will get requested.
     */
	public func retrieveAds(limit: UInt, imageType: EImageType = EImageType.allImages) {
		let nativeAdURL = getNativeAdsURL(self.adPlacementToken, limit: limit, imageType: imageType)
		Logger.debugf("Invoking: %@", nativeAdURL)
		if let url = NSURL(string: nativeAdURL) {
			let task = self.session!.dataTaskWithURL(url, completionHandler: receivedAds)
            task.resume()
		}
	}

	/**
     Method is called as a completionHandler when we hear back from the server
     - data: The NSData object which contains the server response
     - response: The NSURLResponse type which indicates what type of response we got back.
     - error: The error object tells us if there was an error during the external request.
     */
	internal func receivedAds(data: NSData?, response: NSURLResponse?, error: NSError?) {
        Logger.debug("WTF")
		if error != nil {
			self.delegate?.didReceiveError(error!)
			return
		}
		if data == nil {
			self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: data is a nil value.": NSLocalizedDescriptionKey]))
			return
		}
		if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
			mapElements(json)
		} else {
			self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: Not json.": NSLocalizedDescriptionKey]))
		}
	}

	/**
     This method takes charge of mapping the NSArray into an array of nativeAds instances and call the NativeAdsConnectionDelegate with an error or results method.
     Called from receivedAds.
     - jsonArray: The json array.
     */
	internal func mapElements(jsonArray: NSArray) {
		let elements = jsonArray.filter({
			($0 as? NSDictionary) != nil
		})
		var nativeAds: [NativeAd] = []
		for element in elements {
			do {
				let ad = try NativeAd(adDictionary: element as! NSDictionary, adPlacementToken: self.adPlacementToken!)
				nativeAds.append(ad)
			} catch let error as NSError {
				self.delegate?.didReceiveError(error)
				return
			}
		}
		if nativeAds.count > 0 {
			self.delegate?.didReceiveResults(nativeAds)
		} else {
			let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
			let error = NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: userInfo)
			self.delegate?.didReceiveError(error)
		}
	}

	/**
     This method returns the UUID of the device.
     */
	func provideIdentifierForAdvertisingIfAvailable() -> String? {
		return ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString
	}

	/**
     Returns the API URL to invoke to retrieve ads
     */
	public func getNativeAdsURL(placementKey: String?, limit: UInt, imageType: EImageType = EImageType.allImages) -> String {
		let token = provideIdentifierForAdvertisingIfAvailable()

		let baseUrl = NativeAdsConstants.NativeAds.baseURL;
		// token
		var apiUrl = baseUrl + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)&token=\(token!)&placement_key=\(placementKey!)&image_type=\(imageType.rawValue)"

		if (advertisingTrackingEnabled == nil || advertisingTrackingEnabled == false) {
			apiUrl = apiUrl + "&optout=1"
		}

		return apiUrl
	}

}