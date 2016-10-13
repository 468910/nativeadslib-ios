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
 Class that is used to public the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpenerProtocol
 **/
public class FullscreenBrowser: UIViewController, NativeAdOpenerProtocol {

	internal var originalViewController: UIViewController?

	internal var webView: UIWebView?
	internal var webViewDelegate: NativeAdsWebviewDelegate?

	@objc
	internal init(parentViewController: UIViewController) {
		super.init(nibName: nil, bundle: Bundle.main)

		self.originalViewController = parentViewController
		if (self.originalViewController!.view.bounds.width != 0 && self.originalViewController!.view.bounds.height != 0) {
			setupWebView(self.originalViewController!.view.bounds.width, height: self.originalViewController!.view.bounds.height)
		}
        else {
			setupWebView(UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
        _ width: CGFloat,
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
		blackView.backgroundColor = UIColor.white
		webView!.addSubview(blackView)
	}

	fileprivate func addCloseButton() {
		let button = UIButton(type: UIButtonType.system)
		button.frame = CGRect(x: UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.10, y: 0, width: UIScreen.main.bounds.width * 0.10, height: UIScreen.main.bounds.height * 0.10)
		button.backgroundColor = UIColor.clear
		button.setImage(UIImage(named: "close"), for: UIControlState())
		button.addTarget(self, action: .closeAction, for: UIControlEvents.touchUpInside)
		self.view.addSubview(button)
	}

	fileprivate func show(_ adUnit: NativeAd) {
		self.webViewDelegate!.loadUrl(adUnit)
	}

	/**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
	@objc
	public func load(_ adUnit: NativeAd) {
		// In case the original controller is attached to a UINavigationController, we use it
		// to push our new fullscreen browser
		if self.originalViewController!.navigationController != nil {
			self.show(adUnit)
		} else {
			// If the original view controller doesn't have an UINavigationController
			// we will display a new view
			addCloseButton()
			self.originalViewController!.present(self, animated: true, completion: { () -> Void in
				self.show(adUnit)
			})
		}
	}

	@objc
	public func didOpenBrowser(_ url: URL) {
		if let _ = self.originalViewController?.navigationController {
			self.originalViewController?.navigationController?.popViewController(animated: true)
		} else {
			self.closeAction()
		}
	}
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

	override public func willMove(toParentViewController parent: UIViewController?) {
		if parent == nil {
			self.webView!.stopLoading()
		}
	}

	internal func closeAction() {
		self.webView!.stopLoading()
		self.dismiss(animated: true, completion: nil)
	}

}
