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
 NativeAdsRequest is a controller class that will do a network request and call a instance of NativeAdsConnectionDelegate based on the results.
 */
open class NativeAdsRequest: NSObject, NSURLConnectionDelegate, UIWebViewDelegate {

    /// Object to notify about the updates related with the ad request
    open var delegate: NativeAdsConnectionDelegate?
    /// Needed to identify the ad requests to the server
    open var adPlacementToken: String?
    /// Check whether advertising tracking is limited
    open var advertisingTrackingEnabled: Bool? = false
    /// URL session used to do network requests.
    open var session: URLSession?

    /**
     NativeAdsRequest is a controller class that will do a network request and call a instance of NativeAdsConnectionDelegate based on the results.
     - parameter withAdPlacementToken: The placement token received from http://third-party.pmgbrain.com/
     - paramter delegate: instance of NativeAdsConnectionDelegate that will be informed about the network call results.
     - parameter advertisingTrackingEnabled: Boolean defining if the tracking token is enabled. If none specified system boolean is used.
     - parameter session: A instance of URLSession to the network requests with.
     */
    @objc
    public init(withAdPlacementToken: String?,
                delegate: NativeAdsConnectionDelegate?
    ) {
        super.init()
        self.adPlacementToken = withAdPlacementToken
        self.delegate = delegate
        self.advertisingTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        self.session = URLSession.shared
    }

    // not objc compatible because of the usage of URLSessionProtocol
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
     - parameter limit: Limit on how many native ads are to be retrieved.
     - parameter imageType: Image Type is used to specify what kind of image type will get requested.
     */
    @objc
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
     - parameter data: The NSData object which contains the server response
     - parameter response: The NSURLResponse type which indicates what type of response we got back.
     - parameter error: The error object tells us if there was an error during the external request.
     */
    internal func receivedAds(_ data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegateDidReceiveError(error!)
            return
        }
        if data == nil {
            delegateDidReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: data is a nil value.": NSLocalizedDescriptionKey]))
            return
        }
        if let json: NSArray = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSArray {
            mapAds(json)
        } else {
            delegateDidReceiveError(NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: ["Invalid server response received: Not json.": NSLocalizedDescriptionKey]))
        }
    }

    /**
     This function wraps around the call to the delegate. It will make sure that the call to delegate is called on the main thread. Because there is a high likelyhood that the user will do UI changes the moment the call comes in.
     - parameter error: The error sent to the delegate.
     */
    private func delegateDidReceiveError(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate?.didReceiveError(error)
        }
    }

    /**
     This function wraps around the call to the delegate. It will make sure that the call to delegate is called on the main thread. Because there is a high likelyhood that the user will do UI changes the moment the call comes in.
     - parameter nativeads: The result of ads sent to the delegate.
     */
    private func delegateDidReceiveResults(_ nativeAds: [NativeAd]) {
        DispatchQueue.main.async {
            self.delegate?.didReceiveResults(nativeAds)
        }
    }

    /**
     This method takes charge of mapping the NSArray into an array of nativeAds instances and call the NativeAdsConnectionDelegate with an error or results method.
     Called from receivedAds.
     - jsonArray: The json array.
     */
    internal func mapAds(_ jsonArray: NSArray) {
        let ads = jsonArray.filter({
            ($0 as? Dictionary<String, Any>) != nil
        })
        var nativeAds: [NativeAd] = []
        for ad in ads {
            do {
                if let adDict = ad as? Dictionary<String, Any> {
                    let ad = try NativeAd(adDictionary: adDict, adPlacementToken: self.adPlacementToken!)
                    nativeAds.append(ad)
                }
            } catch let error as NSError {
                delegateDidReceiveError(error)
                return
            }
        }
        if nativeAds.count > 0 {
            delegateDidReceiveResults(nativeAds)
        } else {
            let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
            let error = NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: userInfo)
            delegateDidReceiveError(error)
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
        apiUrl += "&image_type=\(imageType.description)"

        if advertisingTrackingEnabled == nil || advertisingTrackingEnabled == false {
            apiUrl = apiUrl + "&optout=1"
        }

        return apiUrl
    }
}
