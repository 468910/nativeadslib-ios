//
//  FullscreenBrowser.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 18/01/16.
//
//

import UIKit

/**
 Default controller class that is used to open the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpener
 */
@objc(FullScreenBrowser)
public class FullScreenBrowser: UIViewController, NativeAdOpener {
    /// Instance of the delegate we need to inform about events happening here.
    internal var webViewDelegate: NativeAdsWebviewDelegate?
    /// The original viewController. To give some context of where we were, so if the user cancels we can go back.
    internal var parentController: UIViewController?
    /// The actual webView we are controlling here.
    @IBOutlet weak var webView: UIWebView?
    /// The close button.
    @IBOutlet weak var closeButton: UIButton?
    /// The ad that this controller needs to load.
    private var ad: NativeAd?
    /// The delegate we need to inform about the status
    internal var delegate: NativeAdOpenerDelegate?

    /**
     Initializes the FullScreen Embedded WebView native ad opener.
     */
    @objc
    public init(delegate: NativeAdOpenerDelegate? = nil, parent viewController: UIViewController? = nil) {
        self.delegate = delegate
        super.init(nibName: "FullScreenBrowser", bundle: PocketMediaNativeAdsBundle.loadBundle()!)
        // Does the given viewController have a navigationController?
        if viewController?.navigationController != nil {
            self.parentController = viewController
        } else {
            self.parentController = getRootView()
        }
    }

    internal func getRootView() -> UIViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController
    }

    /**
     Required to be implemented. Do not use this initializer.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Called when the view dissapears.
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webViewDelegate?.stop()
        delegate?.openerStopped()
    }

    /**
     Called once the view loaded.
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        setupWebView()
        run()
    }

    /**
     Returns if the view is ready.
     */
    internal func ready() -> Bool {
        return self.isViewLoaded
    }

    /**
     Attach delegate to the webview.
     - Important:
     WebView must already be defined at this stage.
     */
    internal func setupWebView(delegate: NativeAdsWebviewDelegate? = nil) {
        guard ready() else {
            return
        }
        self.webViewDelegate = delegate != nil ? delegate : NativeAdsWebviewDelegate(delegate: self, webView: self.webView!)
        self.webView?.delegate = self.webViewDelegate
    }

    /**
     Show this uiViewController
     */
    internal func show(animate: Bool = true) {
        if self.parentController?.navigationController != nil {
            self.parentController?.navigationController?.pushViewController(self, animated: animate)
            return
        }
        self.setRootView(view: self)
    }

    /**
     Hides this uiViewController
     */
    internal func hide(animate: Bool = true) {
        if self.parentController?.navigationController != nil {
            self.parentController?.navigationController?.popViewController(animated: animate)
            return
        }
        self.setRootView(view: self.parentController!)
    }

    /**
     Inform the webviewDelegate to start loading the ad.
     */
    internal func run() {
        guard ready() else {
            show()
            return
        }

        if let ad = self.ad {
            self.webViewDelegate?.loadUrl(ad)
            delegate?.openerStarted()
        } else {
            DispatchQueue.main.async {
                self.hide()
            }
        }
    }

    /**
     Called when the user clicks on the close button.
     -Important:
     Only relevant when there isn't a NavigationController attached the parent UIViewController
     */
    @IBAction func Close(_ sender: Any) {
        hide()
    }

    internal func setupCloseButton() {
        if self.parentController?.navigationController != nil {
            closeButton?.isHidden = true
        }
    }

    /**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
    @objc
    open func load(_ ad: NativeAd) {
        self.ad = ad
        run()
    }

    /**
     Will be invoked when the external browser is opened with the final URL
     */
    public func didOpenBrowser(_ url: URL) {
        hide(animate: false)
    }
}
