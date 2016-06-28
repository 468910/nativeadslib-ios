//
//  NativeAdsWebviewDelegate.swift
//  Pods
//
//  Created by Adrián Moreno Peña | Pocket Media on 15/01/16.
//
//

import UIKit
import Foundation


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
    public var webView : UIWebView?
    public var nativeAdUnit : NativeAd?
  
    private var loadStatusCheckTimer : NSTimer?

    private var delegate : NativeAdsWebviewRedirectionsDelegate?
    
    @objc
  public init(delegate : NativeAdsWebviewRedirectionsDelegate?, webView: UIWebView) {
        super.init()
        self.delegate = delegate
        self.webView = webView
      
    }
  
   public func toggleDebugMode(){
      debugModeEnabled = !debugModeEnabled
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
      
      // Ignore NSURLErrorDomain error -999.
      if (error!.code == NSURLErrorCancelled){
        return
      }
      
      // Ignore "Frame Load Interrupted" errors. Seen after app store links.
      if (error!.code == 102) {
        NSLog("FrameLoad Error supressed")
        return
      }
      

        if(checkIfAppStoreUrl(webView.request!)){
          self.openSystemBrowser(webView.request!.URL!)
          NSLog("Could not open URL")
        } else if loadStatusCheckTimer == nil {
         notifyServerOfFalseRedirection()
        }
        
       
      
      if let description = error?.description{
        NSLog("DidFailLoadWithError: %@", description)
      }
      
    }
 
  public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
    
      if(checkIfAppStoreUrl(request)){
        webView.stopLoading()
        NSLog("Url is final for itunes. Opening in the browser: %@", (request.URL?.absoluteString)!)
        openSystemBrowser((request.URL!))
        return false;
      }else{
        return true
      }
    
    NSLog("shouldStartLoadWithRequest")
   
    
  }
  
  
  
  public func checkIfAppStoreUrl(request: NSURLRequest) -> Bool{
    
    if let host = request.URL?.host{
    if(host.hasPrefix("itunes.apple.com") || host.hasPrefix("appstore.com")){
      return true
      }
    }
    else if let finalUrl = request.URL?.absoluteString {
      if(finalUrl.lowercaseString.hasPrefix("itms")){
      return true
      }
    }
    return false
    
    
  }
  
  
    
    public func webViewDidStartLoad(webView: UIWebView) {
        NSLog("webViewDidStartLoad")
      if(loadingView == nil){
        self.createLoadingIndicator(webView)
      }
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        if(loadStatusCheckTimer == nil){
        self.loadStatusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: .notifyServer, userInfo: nil, repeats: false)
        }
    }
  
  
  
    @objc
    public func loadUrl(urlString: String, nativeAdUnit: NativeAd){
      
      self.nativeAdUnit = nativeAdUnit
      let url  = nativeAdUnit.clickURL
      let request = NSURLRequest(URL: url!)
      self.webView!.loadRequest(request)
      NSLog("webview LoadUrl Exited")
  
    }
  
    @objc
    private func notifyServerOfFalseRedirection(){
        
      var url = NSURL(string: NativeAdsConstants.NativeAds.notifyBadAdsUrl)
      var req = NSMutableURLRequest(URL: url!)
      
      var dataBody = constructDataBodyForNotifyingServerOfFalseRedirection()
      NSLog("Full databody: " + dataBody)
      
      req.HTTPMethod = "POST"
      req.HTTPBody = dataBody.dataUsingEncoding(NSUTF8StringEncoding);
      
      var dataTask = NSURLSession.sharedSession().downloadTaskWithRequest(req){
        data, response, error in
        if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode != 200 {
            NSLog("Error notifying the server: \(response)")
            return
          }
        }
        
        if error != nil {
          NSLog("\(error.debugDescription)")
        }
        
      }
      dataTask.resume()
      
      redirectToOfferEngine()
     
    }
  
    private func constructDataBodyForNotifyingServerOfFalseRedirection() -> String{
      var finalUrl : String = webView!.request!.URL!.absoluteString
      var offerid = String(nativeAdUnit!.offerId!)
      var adPlacementToken = String(nativeAdUnit!.adPlacementToken!)
      var userToken =  "userToken=" + NativeAdsConstants.NativeAds.userToken + "&"
      var dataBody = userToken + "offer_id=\(offerid)"  +  "&placement_id=\(adPlacementToken)" +  "&final_url=\(finalUrl)"
      return dataBody
    }
  
    private func redirectToOfferEngine(){
        NSLog("Open System Browser with Redirection Url")
        let string = NativeAdsConstants.NativeAds.redirectionOfferEngineUrl
        let validString = (string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        let url = NSURL(string: validString)
        let request = NSURLRequest(URL: url!)
        self.webView!.stopLoading()
        self.webView!.loadRequest(request)
        NSLog("Done")
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
        
        delegate!.didOpenBrowser(url)
        
    }
  
  
  
    private func createLoadingIndicator(parentView : UIView){
        
        // Box config:
        loadingView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
        loadingView!.center = parentView.center
        loadingView!.backgroundColor = UIColor.blackColor()
        loadingView!.alpha = 0.9
        loadingView!.layer.cornerRadius = 10
        
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
        loadingView!.addSubview(activityView)
        loadingView!.addSubview(textLabel)
        parentView.addSubview(loadingView!)
  
    }
}

extension Selector {
  static let notifyServer = #selector(NativeAdsWebviewDelegate.notifyServerOfFalseRedirection)
}
