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
open class NativeAdsRequest: NSObject, NSURLConnectionDelegate, UIWebViewDelegate {

    /// Object to notify about the updates related with the ad request
    open var delegate: NativeAdsConnectionDelegate?
    /// Needed to identify the ad requests to the server
    open var adPlacementToken: String?
    /// Check whether advertising tracking is limited
    open var advertisingTrackingEnabled: Bool? = false
    /// URL session used to do network requests.
    open var session: URLSession? = nil

    public init(adPlacementToken: String?,
                delegate: NativeAdsConnectionDelegate?,
                advertisingTrackingEnabled: Bool = ASIdentifierManager.shared().isAdvertisingTrackingEnabled,
                session: URLSession = URLSession.shared
    ) {
        super.init()
        self.adPlacementToken = adPlacementToken
        self.delegate = delegate
        self.advertisingTrackingEnabled = advertisingTrackingEnabled
        self.session = session
    }

    /**
     Method used to retrieve native ads which are later accessed by using the delegate.
     - limit: Limit on how many native ads are to be retrieved.
     -  imageType: Image Type is used to specify what kind of image type will get requested.
     */
    open func retrieveAds(_ limit: UInt, imageType: EImageType = EImageType.allImages) {
        let nativeAdURL = getNativeAdsURL(self.adPlacementToken, limit: limit, imageType: imageType)
        Logger.debugf("Invoking: %@", nativeAdURL)
        if let url = URL(string: nativeAdURL) {
            let task = self.session!.dataTask(with: url, completionHandler: receivedAds)
            task.resume()
        }
    }

    /**
     Method is called as a completionHandler when we hear back from the server
     - data: The NSData object which contains the server response
     - response: The NSURLResponse type which indicates what type of response we got back.
     - error: The error object tells us if there was an error during the external request.
     */
    internal func receivedAds(_ data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            self.delegate?.didReceiveError(error!)
            return
        }
        if data == nil {
            self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: data is a nil value.": NSLocalizedDescriptionKey]))
            return
        }
        if let json: NSArray = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSArray {
            mapAds(json)
        } else {
            self.delegate?.didReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: Not json.": NSLocalizedDescriptionKey]))
        }
    }

    /**
     This method takes charge of mapping the NSArray into an array of nativeAds instances and call the NativeAdsConnectionDelegate with an error or results method.
     Called from receivedAds.
     - jsonArray: The json array.
     */
    internal func mapAds(_ jsonArray: NSArray) {
        let ads = jsonArray.filter({
            ($0 as? NSDictionary) != nil
        })
        var nativeAds: [NativeAd] = []
        for ad in ads {
            do {
                if let adDict = ad as? NSDictionary {
                    let ad = try NativeAd(adDictionary: adDict, adPlacementToken: self.adPlacementToken!)
                    nativeAds.append(ad)
                }
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
    fileprivate func provideIdentifierForAdvertisingIfAvailable() -> String? {
        return ASIdentifierManager.shared().advertisingIdentifier?.uuidString
    }

    /**
     Returns the API URL to invoke to retrieve ads
     */
    internal func getNativeAdsURL(_ placementKey: String?, limit: UInt, imageType: EImageType = EImageType.allImages) -> String {
        let token = provideIdentifierForAdvertisingIfAvailable()

        let baseUrl = NativeAdsConstants.NativeAds.baseURL
        // Version
        var apiUrl = baseUrl + "&req_version=002"
        // OS
        apiUrl += "&os=ios"
        // Limit
        apiUrl += "&limit=\(limit)"
        // Version
        apiUrl += "&version=\(NativeAdsConstants.Device.iosVersion)"
        // Model
        apiUrl += "&model=\(NativeAdsConstants.Device.model)"
        // Token
        apiUrl += "&token=\(token!)"
        // Placement key
        apiUrl += "&placement_key=\(placementKey!)"
        // Image type
        apiUrl += "&image_type=\(imageType.rawValue)"

        if advertisingTrackingEnabled == nil || advertisingTrackingEnabled == false {
            apiUrl = apiUrl + "&optout=1"
        }

        return apiUrl
    }
}
