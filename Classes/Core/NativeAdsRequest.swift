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
public class NativeAdsRequest: NSObject, NSURLConnectionDelegate, UIWebViewDelegate {

	/// Object to notify about the updates related with the ad request
	public var delegate: NativeAdsConnectionDelegate?
	/// Needed to identify the ad requests to the server
	public var adPlacementToken: String?
	/// To allow more verbose logging and behaviour
	public var debugModeEnabled: Bool = false
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
     */
	@objc
	public func retrieveAds(limit: UInt) {
		let nativeAdURL = getNativeAdsURL(self.adPlacementToken, limit: limit)
		NSLog("Invoking: %@", nativeAdURL)
		if let url = NSURL(string: nativeAdURL) {
			self.session!.dataTaskWithURL(url, completionHandler: receivedAds)
		}
	}

	internal func receivedAds(data: NSData?, response: NSURLResponse?, error: NSError?) {
		if error != nil {
			self.delegate?.didReceiveError(error!)
		} else {

			var nativeAds: [NativeAd] = []
			if data != nil {
				if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {

					json.filter({ ($0 as? NSDictionary) != nil }).forEach({ (element) -> () in
                        do {
                            let ad = try NativeAd(adDictionary: element as! NSDictionary, adPlacementToken: self.adPlacementToken!)
                            nativeAds.append(ad)
                        } catch let error as NSError  {
                            NSLog("Native Ad Constructor failed to return ad because: %@", error.localizedDescription)
                        }
					})

					if nativeAds.count > 0 {
						self.delegate?.didReceiveResults(nativeAds)
					} else {
						let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
						let error = NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: userInfo)
						self.delegate?.didReceiveError(error)
					}

				} else {
					self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: Not json.": NSLocalizedDescriptionKey]))
				}
			} else {
				self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: data is a nil value.": NSLocalizedDescriptionKey]))
			}

		}
	}

	func provideIdentifierForAdvertisingIfAvailable() -> String? {
		return ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString
	}

	/**
     Returns the API URL to invoke to retrieve ads
     */
	public func getNativeAdsURL(placementKey: String?, limit: UInt) -> String {
		let token = provideIdentifierForAdvertisingIfAvailable()

		let baseUrl = NativeAdsConstants.NativeAds.baseURL;
		// token
		var apiUrl = baseUrl + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)"
		apiUrl = apiUrl + "&token=" + token!
		apiUrl = apiUrl + "&placement_key=" + placementKey!

		if (advertisingTrackingEnabled == nil || advertisingTrackingEnabled == false) {
			apiUrl = apiUrl + "&optout=1"
		}

		return apiUrl
	}

}
