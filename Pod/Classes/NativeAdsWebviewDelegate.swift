//
//  NativeAdsWebviewDelegate.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 15/01/16.
//
//

import UIKit


/**
 Protocol to be implemented by the classes that want to implement some behaviour
 when the final url was opened in the external browser (this will usually an app store one)
*/
@objc
public protocol NativeAdsWebviewRedirectionsDelegate {
    /// Will be invoked when the external browser is opened with the final URL
    func didOpenBrowser(url: NSURL)
}

/**
 Creates a webview with a native load indicator to tell the user we are loading some content
 */
@objc
public class NativeAdsWebviewDelegate: NSObject, UIWebViewDelegate{

    // To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    public var loadingView : UIView?

    private var delegate : NativeAdsWebviewRedirectionsDelegate?
    
    @objc
    public init(debugMode : Bool, delegate : NativeAdsWebviewRedirectionsDelegate?) {
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
        
        if let description = error?.description{
            NSLog("DidFailLoadWithError: %@", description)
        }
        let finalUrl : NSURL = NSURL(string: (error?.userInfo["NSErrorFailingURLStringKey"])! as! String)!
        webView.stopLoading()
        self.openSystemBrowser(finalUrl)
        NSLog("Could not open URL")
        
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //NSLog("Loading %@", (request.URL?.absoluteString)!)
        
        if ( request.URL?.absoluteString.rangeOfString("itunes.apple.com") != nil) {
            NSLog("Url is final for itunes. Opening in the browser: %@", (request.URL?.absoluteString)!)
            openSystemBrowser((request.URL!))
            return false;
        }
        
        return true;
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        self.createLoadingIndicator(webView)
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        loadingView?.hidden = true
    }
    

    /**
    Opens the system URL, will be invoked when we must not display the URL in the webview.
    */
    public func openSystemBrowser(url : NSURL){
        
        let urlToOpen : NSURL = checkSimulatorURL(url)
        if (debugModeEnabled){
            NSLog("\n\nRequesting to Safari: %@\n\n", urlToOpen.absoluteString)
        }
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
        
        delegate?.didOpenBrowser(url)
        
    }
    
    private func createLoadingIndicator(parentView : UIView){
        
        // Box config:
        let loadingView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
        loadingView.center = parentView.center
        loadingView.backgroundColor = UIColor.blackColor()
        loadingView.alpha = 0.9
        loadingView.layer.cornerRadius = 10
        
        // Spin config:
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        activityView.startAnimating()
        
        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."
        
        // Activate:
        loadingView.addSubview(activityView)
        loadingView.addSubview(textLabel)
        parentView.addSubview(loadingView)
        
    }

    
    
}