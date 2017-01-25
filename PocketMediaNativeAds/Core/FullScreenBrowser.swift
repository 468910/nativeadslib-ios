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
 Default implementation for the NativeAdOpenerDelegate
 */
@objc(FullScreenBrowser)
public class FullScreenBrowser: UIViewController, NativeAdOpener {
    /// Instance of the delegate we need to inform about events happening here.
    internal var webViewDelegate: NativeAdsWebviewDelegate?
    /// The original viewController. To give some context of where we were, so if the user cancels we can go back.
    private var parentController: UIViewController?
    /// The actual webView we are controlling here.
    @IBOutlet weak var webView: UIWebView?
    ///The close button.
    @IBOutlet weak var closeButton: UIButton?
    private var ad: NativeAd?
    private var delegate : NativeAdOpenerDelegate?
    
    /**
     Initializes the FullScreen Embedded WebView native ad opener.
     */
    @objc
    public init(delegate: NativeAdOpenerDelegate? = nil, parent viewController: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) {
        self.delegate = delegate
        super.init(nibName: "FullScreenBrowser", bundle: PocketMediaNativeAdsBundle.loadBundle()!)
        //Does the given viewController have a navigationController?
        if viewController?.navigationController != nil {
            self.parentController = viewController
        } else {
            self.parentController = UIApplication.shared.delegate?.window??.rootViewController
        }
    }
    
    /**
     Required to be implemented. Do not use this initializer.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webViewDelegate?.stop()
        delegate?.openerStopped()
    }
    
    open override func viewDidLoad()  {
        super.viewDidLoad()
        setupCloseButton()
        setupWebView()
        run()
    }

    /**
     Show this uiViewController
    */
    func show(animate: Bool = true) {
        DispatchQueue.main.async {
            if self.parentController?.navigationController != nil {
                self.parentController?.navigationController?.pushViewController(self, animated: animate)
            } else {
                if let window = UIApplication.shared.keyWindow {
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        let oldState: Bool = UIView.areAnimationsEnabled
                        UIView.setAnimationsEnabled(false)
                        window.rootViewController = self
                        UIView.setAnimationsEnabled(oldState)
                    }, completion: nil)
                }
            }
        }

    }
    
    func hide(animate: Bool = true) {
        DispatchQueue.main.async {
            if self.parentController?.navigationController != nil {
                self.parentController?.navigationController?.popViewController(animated: animate)
            } else {
                if let window = UIApplication.shared.keyWindow {
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        let oldState: Bool = UIView.areAnimationsEnabled
                        UIView.setAnimationsEnabled(false)
                        window.rootViewController = self.parentController
                        UIView.setAnimationsEnabled(oldState)
                    }, completion: nil)
                }
            }
        }
    }
    
    func run() {
        if !self.isViewLoaded {
            show()
            return
        }
        
        if let ad = self.ad {
            self.webViewDelegate!.loadUrl(ad)
            delegate?.openerStarted()
        } else {
            hide()
        }
    }
    
    @IBAction func Close(_ sender: Any) {
        hide()
    }
    
    fileprivate func setupCloseButton() {
        if self.parentController?.navigationController != nil {
            closeButton?.isHidden = true
        }
    }
    
    internal func setupWebView(delegate: NativeAdsWebviewDelegate? = nil) {
        self.webViewDelegate = delegate != nil ? delegate : NativeAdsWebviewDelegate(delegate: self, webView: self.webView!)
        self.webView?.delegate = self.webViewDelegate
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
    
    /// Will be invoked when the external browser is opened with the final URL
    public func didOpenBrowser(_ url: URL) {
        hide(animate: false)
    }
    
}
