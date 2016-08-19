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
 Protocol to be implemented by the classes that want to implement some behaviour
 when the final url was opened in the external browser (this will usually an app store one)
 */
@objc
public protocol NativeAdsWebviewRedirectionsDelegate {
	/// Will be invoked when the external browser is opened with the final URL
	func didOpenBrowser(url: NSURL)
}

/**
 Creates a webview with a native load indicator to tell the user we are loading some content
 */
@objc
public class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate {

	// To allow more verbose logging and behaviour
	public var debugModeEnabled: Bool = false
	public var loadingView: UIView?
	public var webView: UIWebView?
	public var nativeAdUnit: NativeAd?

	private var loadStatusCheckTimer: NSTimer?

	private var delegate: NativeAdsWebviewRedirectionsDelegate?

	@objc
	public init(delegate: NativeAdsWebviewRedirectionsDelegate?, webView: UIWebView) {
		super.init()
		self.delegate = delegate
		self.webView = webView

	}

	public func toggleDebugMode() {
		debugModeEnabled = !debugModeEnabled
	}

	private func checkSimulatorURL(url: NSURL) -> NSURL {
		if (debugModeEnabled) {
			if (Platform.isSimulator) {

				if (url.scheme != "http" &&
					url.scheme != "https") {

						let modifiedUrl: NSURL = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString("itms-apps", withString: "http"))!
						return modifiedUrl
				}
			}
		}

		return url
	}

	public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {

		// Ignore NSURLErrorDomain error -999.
		if (error!.code == NSURLErrorCancelled) {
			return
		}

		// Ignore "Frame Load Interrupted" errors. Seen after app store links.
		if (error!.code == 102) {
			print("FrameLoad Error supressed")
			return
		}

		if (checkIfAppStoreUrl(webView.request!)) {
			NSLog("Could not open URL. Opening in system browser: \(webView.request?.URL?.absoluteString)")
			self.openSystemBrowser(webView.request!.URL!)
		} else if loadStatusCheckTimer == nil {
			notifyServerOfFalseRedirection()
		}

		if let description = error?.description {
			NSLog("DidFailLoadWithError: %@", description)
		}

	}

	public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

		loadStatusCheckTimer?.invalidate()
		loadStatusCheckTimer = nil
		if (checkIfAppStoreUrl(request)) {
			webView.stopLoading()
			NSLog("Url is final for itunes. Opening in the browser: %@", (request.URL?.absoluteString)!)
			openSystemBrowser((request.URL!))
			return false;
		} else {
			return true
		}

		print("shouldStartLoadWithRequest")

	}

	public func checkIfAppStoreUrl(request: NSURLRequest) -> Bool {
		print(request.URL!.absoluteString)

		if let host = request.URL?.host {
			if (host.hasPrefix("itunes.apple.com") || host.hasPrefix("appstore.com")) {
				print("Has prefix itunes.apple.com or appstore.com")
				return true
			}
		}
		else if let finalUrl = request.URL?.absoluteString {
			if (finalUrl.lowercaseString.hasPrefix("itms")) {
				print("has prefix itms")
				return true
			}
		}
		print(request.URL!.absoluteString + " Returned false")
		return false

	}

	public func webViewDidStartLoad(webView: UIWebView) {
		print("webViewDidStartLoad")
		if (loadingView == nil) {
			self.createLoadingIndicator(webView)
		}
	}

	public func webViewDidFinishLoad(webView: UIWebView) {
		if (loadStatusCheckTimer == nil) {
			self.loadStatusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: .notifyServer, userInfo: nil, repeats: false)
		}
	}

	@objc
	public func loadUrl(urlString: String, nativeAdUnit: NativeAd) {

		self.nativeAdUnit = nativeAdUnit
		let url = nativeAdUnit.clickURL
		let request = NSURLRequest(URL: url!)
		self.webView!.loadRequest(request)
		NSLog("webview LoadUrl Exited")

	}

	@objc
	private func notifyServerOfFalseRedirection() {

		NSLog("Notifying wrong redirect.")

		var url = NSURL(string: NativeAdsConstants.NativeAds.notifyBadAdsUrl)

		var req = NSMutableURLRequest(URL: url!)

		var dataBody = constructDataBodyForNotifyingServerOfFalseRedirection()

		req.HTTPMethod = "POST"
		req.HTTPBody = dataBody.dataUsingEncoding(NSUTF8StringEncoding);

		var dataTask = NSURLSession.sharedSession().downloadTaskWithRequest(req) {
			data, response, error in
			if let httpResponse = response as? NSHTTPURLResponse {
				if httpResponse.statusCode != 200 {
					print("response was not 200: \(response)")
					return
				}
			}

			if error != nil {
				print(error!)
			}

		}
		dataTask.resume()

		// redirectToOfferEngine()
		openSystemBrowser((self.webView?.request?.URL)!)

	}

	private func constructDataBodyForNotifyingServerOfFalseRedirection() -> String {
		var finalUrl: String = webView!.request!.URL!.absoluteString
		var offerid = String(nativeAdUnit!.offerId!)
		var adPlacementToken = String(nativeAdUnit!.adPlacementToken!)
		var userToken = "userToken=" + NativeAdsConstants.NativeAds.userToken + "&"
		var dataBody = userToken + "offer_id=\(offerid)" + "&placement_id=\(adPlacementToken)" + "&final_url=\(finalUrl)"
		return dataBody
	}

	private func redirectToOfferEngine() {
		print("Open System Browser with Redirection Url")
		let string = NativeAdsConstants.NativeAds.redirectionOfferEngineUrl
		let validString = (string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
		let url = NSURL(string: validString)
		let request = NSURLRequest(URL: url!)
		self.webView!.stopLoading()
		self.webView!.loadRequest(request)
		print("Done")
	}

	/**
	 Opens the system URL, will be invoked when we must not display the URL in the webview.
	 */
	public func openSystemBrowser(url: NSURL) {

		let urlToOpen: NSURL = checkSimulatorURL(url)
		if (debugModeEnabled) {
			NSLog("\n\nRequesting to Safari: %@\n\n", urlToOpen.absoluteString)
		}
		if UIApplication.sharedApplication().canOpenURL(url) {
			UIApplication.sharedApplication().openURL(url)
		}

		delegate!.didOpenBrowser(url)

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

extension Selector {
	static let notifyServer = #selector(NativeAdsWebviewDelegate.notifyServerOfFalseRedirection)
}
