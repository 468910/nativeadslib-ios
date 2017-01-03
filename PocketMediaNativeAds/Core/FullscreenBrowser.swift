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
 Controller class that is used to open the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpenerDelegate
 */
open class FullscreenBrowser: UIViewController, NativeAdOpenerDelegate {
    /// The original viewController. To give some context of where we are.
    internal var originalViewController: UIViewController?
    /// The actual webView we are controlling here.
    internal var webView: UIWebView?
    /// Instance of the delegate we need to inform about events happening here.
    internal var webViewDelegate: NativeAdsWebviewDelegate?

    /**
     Initializes the FullScreen Embedded WebView native ad opener.
     */
    @objc
    public init(parentViewController: UIViewController) {
        super.init(nibName: nil, bundle: Bundle.main)

        self.originalViewController = parentViewController
        let bounds = self.originalViewController!.view.bounds
        if bounds.width != 0 && bounds.height != 0 {
            setupWebView(bounds.width, height: bounds.height)
        } else {
            setupWebView(UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        addSubView()

        if self.originalViewController!.navigationController != nil {
            self.originalViewController!.navigationController!.pushViewController(self, animated: true)
        }
    }

    /**
     Required to be implemented. Do not use this initializer.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Called at initialization to setup the webView and set self.webView and self.webViewDelegate
     - parameter: width: The width of the webView. (The initializer will use the bounds of a sent viewController, otherwise revert back to the bounds of the device)
     - parameter: height: The height of the webView. (The initializer will use the bounds of a sent viewController, otherwise revert back to the bounds of the device)
     - parameter: the delegate used with this webView. If none specified we'll create a new instance.
     */
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

    /**
     Add black background view in the webview.
     */
    internal func addSubView() {
        if let webView = self.webView {
            let blackView = UIView(frame: CGRect.init(x: 0, y: 0, width: webView.bounds.width, height: webView.bounds.height))
            blackView.backgroundColor = UIColor.white
            webView.addSubview(blackView)
        }
    }

    fileprivate func addCloseButton() {
        let button = UIButton(type: UIButtonType.system)
        button.frame = CGRect(
            x: UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.10, y: 0,
            width: UIScreen.main.bounds.width * 0.10,
            height: UIScreen.main.bounds.height * 0.10
        )
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
    open func load(_ adUnit: NativeAd) {
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

    /**
     Invoked when the external browser is opened with the final URL
     */
    @objc
    open func didOpenBrowser(_ url: URL) {
        if let _ = self.originalViewController?.navigationController {
            _ = self.originalViewController?.navigationController?.popViewController(animated: true)
        } else {
            self.closeAction()
        }
    }

    /**
     Tells the view that its superview is about to change to the specified superview.
     */
    open override func willMove(toParentViewController parent: UIViewController?) {

        if parent == nil {
            self.webView!.stopLoading()
        }
    }

    /**
     Invoked when the user clicks on the close button.
     */
    internal func closeAction() {
        self.webView!.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
}
