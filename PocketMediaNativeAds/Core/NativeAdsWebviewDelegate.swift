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
public class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate {
	internal var loadingView: UIView?
	public var webView: UIWebView?
	public var nativeAdUnit: NativeAd?
	internal var loadStatusCheckTimer: NSTimer?
	private var delegate: NativeAdsWebviewRedirectionsDelegate?

	@objc
	public init(delegate: NativeAdsWebviewRedirectionsDelegate?, webView: UIWebView) {
		super.init()
		self.delegate = delegate
		self.webView = webView
	}

	private func checkSimulatorURL(url: NSURL) -> NSURL {
		#if DEBUG
			if (Platform.isSimulator) {
				if (url.scheme != "http" &&
					url.scheme != "https") {
						let modifiedUrl: NSURL = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString("itms-apps", withString: "http"))!
						return modifiedUrl
				}
			}
		#endif
		return url
	}

	public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
		// Ignore NSURLErrorDomain error -999.
		if (error?.code == NSURLErrorCancelled) {
			return
		}

		// Ignore "Frame Load Interrupted" errors. Seen after app store links.
		if (error?.code == 102) {
			Logger.debug("FrameLoad Error supressed")
			return
		}

		if (webView.request != nil && checkIfAppStoreUrl(webView.request!)) {
			Logger.debug("Could not open URL. Opening in system browser: \(webView.request?.URL?.absoluteString)")
			self.openSystemBrowser(webView.request!.URL!)
		} else if loadStatusCheckTimer == nil {
            notifyServerOfFalseRedirection()
		}

		if let description = error?.description {
			Logger.debugf("DidFailLoadWithError: %@", description)
		}
	}

	public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		loadStatusCheckTimer?.invalidate()
		loadStatusCheckTimer = nil
		if (checkIfAppStoreUrl(request)) {
			webView.stopLoading()
			Logger.debugf("Url is final for itunes. Opening in the browser: %@", (request.URL?.absoluteString)!)
			openSystemBrowser((request.URL!))
			return false
		} else {
			return true
		}
	}

	public func checkIfAppStoreUrl(request: NSURLRequest) -> Bool {
		Logger.debug(request.URL!.absoluteString!)
		if let finalUrl = request.URL?.absoluteString {
			if (finalUrl.lowercaseString.hasPrefix("itms")) {
				Logger.debug("has prefix itms")
				return true
			}
			if let host = request.URL?.host {
				if (host.hasPrefix("itunes.apple.com") || host.hasPrefix("appstore.com")) {
					Logger.debug("Has prefix itunes.apple.com or appstore.com")
					return true
				}
			}
		}
		Logger.debug(request.URL!.absoluteString! + " Returned false")
		return false
	}

	public func webViewDidStartLoad(webView: UIWebView) {
		Logger.debug("webViewDidStartLoad")
		if (loadingView == nil) {
			self.createLoadingIndicator(webView)
		}
	}

	public func webViewDidFinishLoad(webView: UIWebView) {
		if (loadStatusCheckTimer == nil) {
            self.loadStatusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
		}
	}

	@objc
	internal func loadUrl(nativeAdUnit: NativeAd) {
		self.nativeAdUnit = nativeAdUnit
		let url = nativeAdUnit.clickURL
		let request = NSURLRequest(URL: url!)
		self.webView!.loadRequest(request)
		Logger.debug("webview LoadUrl Exited")
	}
    
    //Called when a redirect takes too long.
    public func timeout() {
        Logger.debug("Timed out")
        self.notifyServerOfFalseRedirection()
    }

	@objc
	internal func notifyServerOfFalseRedirection(session: NSURLSession = NSURLSession.sharedSession()) {
		let url = NSURL(string: NativeAdsConstants.NativeAds.notifyBadAdsUrl)
		let req = NSMutableURLRequest(URL: url!)
		let dataBody = constructDataBodyForNotifyingServerOfFalseRedirection()

		req.HTTPMethod = "POST"
		req.HTTPBody = dataBody.dataUsingEncoding(NSUTF8StringEncoding)

		let dataTask = session.downloadTaskWithRequest(req, completionHandler: { data, response, error in
            if error != nil {
                Logger.error("error", error!)
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    Logger.debug("response was not 200: \(response)")
                    return
                }
            }
		})
        dataTask.resume()
        
        //Open the url that won't redirect to something proper.
        //Big chance its an app which is not available anymore in our region.
		if self.webView?.request != nil {
			openSystemBrowser((self.webView?.request?.URL)!)
		}
	}

	private func constructDataBodyForNotifyingServerOfFalseRedirection() -> String {
        let finalUrl: String = (webView != nil && webView!.request != nil) ? webView!.request!.URL!.absoluteString! : ""
		let offerid = String(nativeAdUnit?.offerId!)
		let adPlacementToken = nativeAdUnit?.adPlacementToken
		let dataBody = "offer_id=\(offerid)" + "&placement_id=\(adPlacementToken)" + "&final_url=\(finalUrl)"
		return dataBody
	}

	/**
     Opens the system URL, will be invoked when we must not display the URL in the webview.
     */
	public func openSystemBrowser(url: NSURL) {
		let urlToOpen: NSURL = checkSimulatorURL(url)
		Logger.debugf("\n\nRequesting to Safari: %@\n\n", urlToOpen.absoluteString!)
		if UIApplication.sharedApplication().canOpenURL(url) {
			UIApplication.sharedApplication().openURL(url)
		}
		delegate?.didOpenBrowser(url)
	}

	private func createLoadingIndicator(parentView: UIView) {
		// Box config:
		loadingView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
		loadingView!.center = parentView.center
		loadingView!.backgroundColor = UIColor.blackColor()
		loadingView!.alpha = 0.9
		loadingView!.layer.cornerRadius = 10

		// Spin config:
		let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
		activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
		activityView.startAnimating()

		// Text config:
		let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
		textLabel.textColor = UIColor.whiteColor()
		textLabel.textAlignment = .Center
		textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
		textLabel.text = "Loading..."

		// Activate:
		loadingView!.addSubview(activityView)
		loadingView!.addSubview(textLabel)
		parentView.addSubview(loadingView!)
	}
}
