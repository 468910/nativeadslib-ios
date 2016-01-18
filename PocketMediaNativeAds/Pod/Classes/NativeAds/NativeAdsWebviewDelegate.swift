//
//  NativeAdsWebviewDelegate.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 15/01/16.
//
//

import UIKit


public protocol NativeAdsWebviewRedirectionsProtocol {
    func didOpenBrowser(url: NSURL)
}

public class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate{

    // To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    private var delegate : NativeAdsWebviewRedirectionsProtocol?
    
    public init(debugMode : Bool, delegate : NativeAdsWebviewRedirectionsProtocol?) {
        super.init()
        self.debugModeEnabled = debugMode
        self.delegate = delegate
    }
    
    
    private func checkSimulatorURL(url : NSURL) -> NSURL{
        if (debugModeEnabled){
            if (Platform.isSimulator){
                
                if(url.scheme != "http" &&
                    url.scheme != "https"  ){
                        
                        let modifiedUrl : NSURL = NSURL(string: url.absoluteString.stringByReplacingOccurrencesOfString("itms-apps", withString: "http"))!
                        return modifiedUrl
                        
                }
                
            }
        }
        
        return url
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        let finalUrl : NSURL = NSURL(string: (error?.userInfo["NSErrorFailingURLStringKey"])! as! String)!
        self.openSystemBrowser(finalUrl)
        NSLog("Final URL: \(finalUrl.absoluteString)")
        
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        NSLog("Loading %@", (request.URL?.absoluteString)!)
        return true;
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
    }
    

    public func openSystemBrowser(url : NSURL){
        
        let urlToOpen : NSURL = checkSimulatorURL(url)
        NSLog("Requesting to Safari: %@", urlToOpen.absoluteString)
        UIApplication.sharedApplication().openURL(urlToOpen)
        
        delegate?.didOpenBrowser(url)
        
    }
    
}