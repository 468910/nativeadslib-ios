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
internal class FullscreenBrowser : UIViewController, NativeAdsWebviewRedirectionsDelegate, NativeAdOpenerDelegate {

    private var originalViewController : UIViewController?
    
    private var webView : UIWebView?
    private var webViewDelegate : UIWebViewDelegate?
    
    @objc
    internal init(parentViewController : UIViewController){
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        self.originalViewController = parentViewController
    }

    required internal init?(coder aDecoder: NSCoder)  {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        if (self.webView != nil){
            self.view.addSubview(self.webView!)
        }
    }

    /**
     Starts loading the ad within the current context (controller and navigation)
     - adUnit: adUnit whose ad we want to display
     */
    @objc
   internal func load(adUnit : NativeAd){
        print("\nFollowing link: \(adUnit.clickURL)")
        
        
        if (webView == nil){
            webView = UIWebView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
        }
        
        if (webViewDelegate == nil){
            self.webViewDelegate = NativeAdsWebviewDelegate(debugMode: true, delegate: self)
        }
        
        webView?.delegate = self.webViewDelegate
        
        // In case the original controller is attached to a UINavigationController, we use it
        // to push our new fullscreen browser
        if(((self.originalViewController!.navigationController)) != nil){
            
            if ((webView) != nil){
                self.originalViewController!.navigationController!.pushViewController(self, animated: true)
            }
            
            let request : NSURLRequest = NSURLRequest(URL: (adUnit.clickURL)!)
            webView?.loadRequest(request)
            
        }else{
        // If the originall view controller doesn't have an UINavigationController
        // we will display a new view
            
            let button = UIButton(type: UIButtonType.System)
            button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width * 0.10, 0, UIScreen.mainScreen().bounds.width * 0.10, UIScreen.mainScreen().bounds.height * 0.10)
            button.backgroundColor = UIColor.clearColor()
            button.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
            button.addTarget(self, action: "closeAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(button)
            
            originalViewController!.presentViewController(self, animated: true, completion: { () -> Void in
                let request : NSURLRequest = NSURLRequest(URL: (adUnit.clickURL)!)
                self.webView?.loadRequest(request)
            })

        }
    }
    
    @objc
    internal func didOpenBrowser(url : NSURL){
        
        if let _ = self.originalViewController?.navigationController{
            self.originalViewController?.navigationController?.popViewControllerAnimated(true)
        }else{
            self.closeAction()
        }

        NSLog("Dismissed View Controller for FullScreenBrowser")

    }
    
    internal func closeAction(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}