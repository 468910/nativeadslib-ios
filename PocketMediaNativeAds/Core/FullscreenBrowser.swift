//
//  FullscreenBrowser.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 18/01/16.
//
//

import UIKit

extension Selector {
	static let closeAction = #selector(FullscreenBrowser.closeAction)
}

/**
 Class that is used to open the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpenerProtocol
 **/
public class FullscreenBrowser: UIViewController, NativeAdOpenerProtocol {

	internal var originalViewController: UIViewController?

	internal var webView: UIWebView?
	internal var webViewDelegate: NativeAdsWebviewDelegate?

	@objc
	internal init(parentViewController: UIViewController) {
		super.init(nibName: nil, bundle: NSBundle.mainBundle())

		self.originalViewController = parentViewController
		if (self.originalViewController!.view.bounds.width != 0 && self.originalViewController!.view.bounds.height != 0) {
			setupWebView(self.originalViewController!.view.bounds.width, height: self.originalViewController!.view.bounds.height)
		}
        else {
			setupWebView(UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
		}
		addSubView()

		if self.originalViewController!.navigationController != nil {
			self.originalViewController!.navigationController!.pushViewController(self, animated: true)
		}
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    internal func setupWebView(
        width: CGFloat,
        height: CGFloat,
        delegate: NativeAdsWebviewDelegate? = nil
    ) {
		self.webView = UIWebView(frame: CGRect.init(
			x: 0,
			y: 0,
			width: width,
			height: height
			)
		)
        self.view = self.webView
        
        self.webViewDelegate = delegate != nil ? delegate : NativeAdsWebviewDelegate(delegate: self, webView: self.webView!)
        self.webView!.delegate = self.webViewDelegate
	}

	internal func addSubView() {
		let blackView = UIView(frame: CGRect.init(x: 0, y: 0, width: webView!.bounds.width, height: webView!.bounds.height))
		blackView.backgroundColor = UIColor.whiteColor()
		webView!.addSubview(blackView)
	}

	private func addCloseButton() {
		let button = UIButton(type: UIButtonType.System)
		button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width * 0.10, 0, UIScreen.mainScreen().bounds.width * 0.10, UIScreen.mainScreen().bounds.height * 0.10)
		button.backgroundColor = UIColor.clearColor()
		button.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
		button.addTarget(self, action: .closeAction, forControlEvents: UIControlEvents.TouchUpInside)
		self.view.addSubview(button)
	}

	private func show(adUnit: NativeAd) {
		self.webViewDelegate!.loadUrl(adUnit)
	}

	/**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
	@objc
	public func load(adUnit: NativeAd) {
		// In case the original controller is attached to a UINavigationController, we use it
		// to push our new fullscreen browser
		if self.originalViewController!.navigationController != nil {
			self.show(adUnit)
		} else {
			// If the original view controller doesn't have an UINavigationController
			// we will display a new view
			addCloseButton()
			self.originalViewController!.presentViewController(self, animated: true, completion: { () -> Void in
				self.show(adUnit)
			})
		}
	}

	@objc
	public func didOpenBrowser(url: NSURL) {
		if let _ = self.originalViewController?.navigationController {
			self.originalViewController?.navigationController?.popViewControllerAnimated(true)
		} else {
			self.closeAction()
		}
	}

	override public func willMoveToParentViewController(parent: UIViewController?) {
		if parent == nil {
			self.webView!.stopLoading()
		}
	}

	internal func closeAction() {
		self.webView!.stopLoading()
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}