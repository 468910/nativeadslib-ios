//
//  FullscreenBrowser.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 18/01/16.
//
//

import UIKit
public class FullscreenBrowser : UIViewController, NativeAdsWebviewRedirectionsProtocol {

    private var adUnit : NativeAd?
    public var originalViewController : UIViewController?
    
    public var webView : UIWebView?
    public var webViewDelegate : UIWebViewDelegate?
    
    
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

    public func load(adUnit : NativeAd){
        print("\nFollowing link: \(adUnit.clickURL)")
        
        if (webView == nil){
            webView = UIWebView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
        }
        
        if (webViewDelegate == nil){
            self.webViewDelegate = NativeAdsWebviewDelegate(debugMode: true, delegate: self)
        }
        
        webView?.delegate = self.webViewDelegate
        
        
        if ((webView) != nil){
            self.originalViewController!.navigationController!.pushViewController(self, animated: true)
        }
        
        let request : NSURLRequest = NSURLRequest(URL: (adUnit.clickURL)!)
        webView?.loadRequest(request)
    }
    
    public func didOpenBrowser(url : NSURL){
        self.originalViewController!.navigationController?.popViewControllerAnimated(true)
        NSLog("Dismissed View Controller for FullScreenBrowser")
    }
    
}