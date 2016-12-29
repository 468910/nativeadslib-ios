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
 Creates a webview with a native load indicator to tell the user we are loading some content
 */
@objc
open class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate {
    internal var loadingView: UIView?
    open var wrappedWebView: UIWebView?
    open var nativeAdUnit: NativeAd?
    internal var loadStatusCheckTimer: Timer?
    fileprivate var delegate: NativeAdsWebviewRedirectionsDelegate?
    fileprivate var lastRequest: URLRequest?

    @objc
    public init(delegate: NativeAdsWebviewRedirectionsDelegate?, webView: UIWebView) {
        super.init()
        self.delegate = delegate
        self.wrappedWebView = webView
    }

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

    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
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
        Logger.debug(request.url!.absoluteString + " Returned false")
        return false
    }

    open func webViewDidStartLoad(_ webView: UIWebView) {
        Logger.debug("webViewDidStartLoad")
        if loadingView == nil {
            self.createLoadingIndicator(webView)
        }
    }

    open func webViewDidFinishLoad(_ webView: UIWebView) {
        if loadStatusCheckTimer == nil {
            self.loadStatusCheckTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        }
    }

    @objc
    internal func loadUrl(_ nativeAdUnit: NativeAd) {
        self.nativeAdUnit = nativeAdUnit
        let url = nativeAdUnit.clickURL
        let request = URLRequest(url: url! as URL)
        self.wrappedWebView!.loadRequest(request)
        Logger.debug("webview LoadUrl Exited")
    }

    // Called when a redirect takes too long.
    // We can't instantly call notifyServerOfFalseRedirection from scheduledTimerWithTimeInterval. It throws an exception.
    open func timeout() {
        Logger.debug("Timed out")
        self.notifyServerOfFalseRedirection()
    }

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
                }
            }
        })
        dataTask.resume()

        // Open the url that won't redirect to something proper.
        // Big chance its an app which is not available anymore in our region.
        if self.wrappedWebView?.request != nil {
            openSystemBrowser((self.wrappedWebView?.request?.url)!)
        }
    }

    fileprivate func constructDataBodyForNotifyingServerOfFalseRedirection() -> String {
        let finalUrl: String = (wrappedWebView != nil && wrappedWebView!.request != nil) ? wrappedWebView!.request!.url!.absoluteString : ""
        let offerid = String(describing: nativeAdUnit?.offerId!)
        let adPlacementToken = nativeAdUnit?.adPlacementToken
        let dataBody = "offer_id=\(offerid)" + "&placement_id=\(adPlacementToken)" + "&final_url=\(finalUrl)"
        return dataBody
    }

    /**
     Opens the system URL, will be invoked when we must not display the URL in the webview.
     */
    open func openSystemBrowser(_ url: URL) {
        let urlToOpen: URL = checkSimulatorURL(url)
        Logger.debugf("\n\nRequesting to Safari: %@\n\n", urlToOpen.absoluteString)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
        delegate?.didOpenBrowser(url)
    }

    fileprivate func createLoadingIndicator(_ parentView: UIView) {
        // Box config:
        loadingView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
        loadingView!.center = parentView.center
        loadingView!.backgroundColor = UIColor.black
        loadingView!.alpha = 0.9
        loadingView!.layer.cornerRadius = 10

        // Spin config:
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        activityView.startAnimating()

        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."

        // Activate:
        loadingView!.addSubview(activityView)
        loadingView!.addSubview(textLabel)
        parentView.addSubview(loadingView!)
    }
}
