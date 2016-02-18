//
//  FullscreenBrowser.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 18/01/16.
//
//

import UIKit

/** 
  - Used to display the NativeAd can be safely subclassed.
**/
public class FullscreenBrowser : UIViewController, NativeAdsWebviewRedirectionsProtocol, NativeAdDisplayProtocol {

    private var adUnit : NativeAd?
    public var originalViewController : UIViewController?
    
    public var webView : UIWebView?
    public var webViewDelegate : UIWebViewDelegate?
    
    @objc
    public init(parentViewController : UIViewController, adUnit : NativeAd){
        super.init(nibName: nil, bundle: NSBundle.mainBundle())
        self.originalViewController = parentViewController
        self.adUnit = adUnit
    }

    required public init?(coder aDecoder: NSCoder)  {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        if (self.webView != nil){
            self.view.addSubview(self.webView!)
        }
    }

    @objc
    public func load(adUnit : NativeAd){
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
    public func didOpenBrowser(url : NSURL){
        
        if let _ = self.originalViewController?.navigationController{
            self.originalViewController?.navigationController?.popViewControllerAnimated(true)
        }else{
            self.closeAction()
        }

        NSLog("Dismissed View Controller for FullScreenBrowser")

    }
    
    public func closeAction(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}