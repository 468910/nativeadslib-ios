//
//  NativeAdsWebviewDelegate.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 15/01/16.
//
//

import UIKit
import Foundation

/**
 Controls an instance of a webview. Adds a load indicator to give feedback back to the user.
 It follows each redirect until it reaches the app store or website. Then we'll call the delegate
 */
@objc
open class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate {
    /// The UIWebView we're controlling.
    open var wrappedWebView: UIWebView
    /// The ad we're showing.
    open var nativeAdUnit: NativeAd?
    /// The time since the last redirect.
    internal var loadStatusCheckTimer: Timer?
    /// Delegate to inform once we've hit the final url.
    fileprivate var delegate: NativeAdsWebviewRedirectionsDelegate
    /// The last request we went through.
    fileprivate var lastRequest: URLRequest?
    private var running = false

    /**
     Initializer.
     - parameter delegate: delegate it needs to inform
     - parameter webView: Instance of the webView it will use.
     */
    @objc
    public init(delegate: NativeAdsWebviewRedirectionsDelegate, webView: UIWebView) {
        self.delegate = delegate
        self.wrappedWebView = webView
        super.init()
    }

    /**
     Returns a valid URL. If it is a simulator we'll use the http version.
     */
    fileprivate func checkSimulatorURL(_ url: URL) -> URL {
        #if DEBUG
            if Platform.isSimulator {
                if url.scheme != "http" &&
                    url.scheme != "https" {
                    let modifiedUrl: NSURL = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString("itms-apps", withString: "http"))!
                    return modifiedUrl
                }
            }
        #endif
        return url
    }

    /**
     Sent if a web view failed to load a frame.
     */
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if !running {
            return
        }

        // Ignore NSURLErrorDomain error -999.
        if error._code == NSURLErrorCancelled {
            return
        }

        // The resource could not be loaded because the App Transport Security
        // policy requires the use of a secure connection
        if error._code == -1022 {
            Logger.debug("Error opening insecure URL")
            if let currentUrl = lastRequest?.url {
                Logger.debug("Opening url in browser: \(currentUrl.absoluteString)")
                openSystemBrowser(currentUrl)
            }
        }

        // Ignore "Frame Load Interrupted" errors. Seen after app store links.
        if error._code == 102 {
            Logger.debug("FrameLoad Error supressed")
            return
        }

        if webView.request != nil && checkIfAppStoreUrl(webView.request!) {
            Logger.debug("Could not open URL. Opening in system browser: \(webView.request?.url?.absoluteString)")
            self.openSystemBrowser(webView.request!.url!)
        } else if loadStatusCheckTimer == nil {
            notifyServerOfFalseRedirection()
        }

        Logger.debugf("DidFailLoadWithError: %@", description)
    }

    /**
     Sent before a web view begins loading a frame.
     - Returns:
     False if the requests seems to go in the App Store. True if it isn't.
     */
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        loadStatusCheckTimer?.invalidate()
        loadStatusCheckTimer = nil
        lastRequest = request
        if checkIfAppStoreUrl(request) {
            webView.stopLoading()
            Logger.debugf("Url is final for itunes. Opening in the browser: %@", (request.url?.absoluteString)!)
            openSystemBrowser((request.url!))
            return false
        } else {
            return true
        }
    }

    /**
     Returns true or false if the `request` contains a app store uri.
     */
    open func checkIfAppStoreUrl(_ request: URLRequest) -> Bool {
        //		Logger.debug(request.URL!.absoluteString!)
        if let finalUrl = request.url?.absoluteString {
            if finalUrl.lowercased().hasPrefix("itms") {
                Logger.debug("has prefix itms")
                return true
            }
            if let host = request.url?.host {
                if host.hasPrefix("itunes.apple.com") || host.hasPrefix("appstore.com") {
                    Logger.debug("Has prefix itunes.apple.com or appstore.com")
                    return true
                }
            }
        }
        Logger.debug(request.url!.absoluteString + ": not an appstore url.")
        return false
    }

    /**
     Sent after a web view starts loading a frame. Creates the loading indicator.
     */
    open func webViewDidStartLoad(_ webView: UIWebView) {
        Logger.debug("webViewDidStartLoad")
    }

    /**
     Sent after a web view finishes loading a frame.
     Sets loadStatusCheckTimer so it times out if it takes too long.
     */
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if loadStatusCheckTimer == nil {
            self.loadStatusCheckTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        }
    }

    /**
     Entry point to this class. Will trigger the actual load of an ad.
     */
    @objc
    public func loadUrl(_ nativeAdUnit: NativeAd) {
        running = true
        self.nativeAdUnit = nativeAdUnit
        let request = URLRequest(url: nativeAdUnit.clickURL as URL)

        //if nativeAdUnit.shouldBeManagedExternally {
        //    Logger.debug("AdUnit will open in external browser.")
        //    openSystemBrowser((request.url!))
        //}

        self.wrappedWebView.loadRequest(request)
    }
    
    public func stop() {
        self.wrappedWebView.stopLoading()
        running = false
        self.nativeAdUnit = nil
        Logger.debug("Stopped.")
    }

    /**
     Called when a redirect takes too long.
     - Important:
     We can't instantly call notifyServerOfFalseRedirection from scheduledTimerWithTimeInterval. It throws an exception.
     */
    open func timeout() {
        Logger.debug("Timed out")
        self.notifyServerOfFalseRedirection()
    }

    /**
     This method takes care of informing our backend if an ad doesn't take the user anywhere.
     */
    @objc
    internal func notifyServerOfFalseRedirection(_ session: URLSession = URLSession.shared) {
        let url = URL(string: NativeAdsConstants.NativeAds.notifyBadAdsUrl)
        let req = NSMutableURLRequest(url: url!)
        let dataBody = constructDataBodyForNotifyingServerOfFalseRedirection()

        req.httpMethod = "POST"
        req.httpBody = dataBody.data(using: String.Encoding.utf8)

        let dataTask = session.dataTask(with: url!, completionHandler: { data, response, error in
            if error != nil {
                Logger.error("error", error!)
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    Logger.debug("response was not 200: \(response)")
                    return
                } else {
                    Logger.debug("wrong redirection notified")
                }
            }
        })
        dataTask.resume()

        // Open the url that won't redirect to something proper.
        // Big chance its an app which is not available anymore in our region.
        if self.wrappedWebView.request != nil {
            Logger.debug("Opening system browser after error")
            openSystemBrowser((self.wrappedWebView.request?.url)!)
        }
    }

    /**
     This method will construct the get parameters sent in our notify server of false redirection request.
     */
    fileprivate func constructDataBodyForNotifyingServerOfFalseRedirection() -> String {
        let finalUrl: String = (wrappedWebView.request != nil) ? wrappedWebView.request!.url!.absoluteString : ""
        let offerid = String(describing: nativeAdUnit?.offerId)
        let adPlacementToken = nativeAdUnit?.adPlacementToken
        let dataBody = "offer_id=\(offerid)" + "&placement_id=\(adPlacementToken)" + "&final_url=\(finalUrl)"
        return dataBody
    }

    /**
     Opens the system URL, will be invoked when we must not display the URL in the webview.
     */
    open func openSystemBrowser(_ url: URL) {
        if !running {
            return
        }
        
        let urlToOpen: URL = checkSimulatorURL(url)
        self.loadStatusCheckTimer?.invalidate()
        Logger.debugf("\n\nRequesting to Safari: %@\n\n", urlToOpen.absoluteString)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
        delegate.didOpenBrowser(url)
    }

}
