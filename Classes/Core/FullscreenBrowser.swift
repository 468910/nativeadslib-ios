//
//  FullscreenBrowser.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 18/01/16.
//
//

import UIKit

/**
 Class that is used to open the NativeAd in An FullScreen Embedded WebView.
 Default implementation for the NativeAdOpenerProtocol
 **/
public class FullscreenBrowser: UIViewController, NativeAdOpenerProtocol {
    
    private var originalViewController : UIViewController?
    
    private var webView : UIWebView?
    private var webViewDelegate : NativeAdsWebviewDelegate?
    
    @objc
    internal init(parentViewController : UIViewController){
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        self.originalViewController = parentViewController
    }
    
    required public init?(coder aDecoder: NSCoder)  {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
    @objc
    public func load(adUnit : NativeAd){
        
        if (webView == nil){
            if(self.originalViewController != nil){
                webView = UIWebView(frame: CGRect.init(
                    x: 0,
                    y: 0,
                    width: self.originalViewController!.view.bounds.width,
                    height: self.originalViewController!.view.bounds.height
                    )
                )
            }else{
                webView = UIWebView(frame: CGRect.init(
                    x: 0,
                    y:0,
                    width: UIScreen.mainScreen().bounds.width,
                    height: UIScreen.mainScreen().bounds.height
                    )
                )
            }
            
        }
        
        if (webViewDelegate == nil){
            self.webViewDelegate = NativeAdsWebviewDelegate(delegate: self, webView: webView!)
        }
        
        webView!.delegate = self.webViewDelegate
        self.view = webView
        let blackView = UIView(frame: CGRect.init(x: 0, y: 0, width:  webView!.bounds.width, height: webView!.bounds.height))
        blackView.backgroundColor = UIColor.whiteColor()
        webView!.addSubview(blackView)
        
        // In case the original controller is attached to a UINavigationController, we use it
        // to push our new fullscreen browser
        if(((self.originalViewController!.navigationController)) != nil){
            
            if ((webView) != nil){
                self.originalViewController!.navigationController!.pushViewController(self, animated: true)
            }
            
            self.webViewDelegate!.loadUrl(adUnit.clickURL.absoluteString, nativeAdUnit: adUnit)
            
        }else{
            
            // If the originall view controller doesn't have an UINavigationController
            // we will display a new view
            
            let button = UIButton(type: UIButtonType.System)
            button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width * 0.10, 0, UIScreen.mainScreen().bounds.width * 0.10, UIScreen.mainScreen().bounds.height * 0.10)
            button.backgroundColor = UIColor.clearColor()
            button.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
            button.addTarget(self, action: .closeAction, forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(button)
            
            originalViewController!.presentViewController(self, animated: true, completion: { () -> Void in
                self.webViewDelegate!.loadUrl(adUnit.clickURL.absoluteString, nativeAdUnit: adUnit)
            })
            
        }
    }
    
    @objc
    public func didOpenBrowser(url : NSURL) {
        
        if let _ = self.originalViewController?.navigationController{
            self.originalViewController?.navigationController?.popViewControllerAnimated(true)
            
        }else{
            self.closeAction()
        }
        
    }
    
    override public func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.webView?.stopLoading()
        }
    }
    
    internal func closeAction() {
        self.webView?.stopLoading()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}


extension Selector {
    static let closeAction = #selector(FullscreenBrowser.closeAction)
}