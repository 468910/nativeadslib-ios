//
//  AsynchronousRequest.swift
//  DiscoveryApp
//
//  Created by Carolina Barreiro Cancela on 28/05/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import AdSupport

public class NativeAdsRequest : NSObject, NSURLConnectionDelegate, UIWebViewDelegate {
    
    // Object to notify about the updates related with the ad request
    public var delegate: NativeAdsConnectionProtocol?
    // Needed to "sign" the ad requests to the server
    public var affiliateId : String?
    // To allow more verbose logging and behaviour
    public var debugModeEnabled : Bool = false
    // To allow testing with links without impacting impressions and clicks
    public var betaModeEnabled : Bool = false
    
    // Background redirects //
    public var followRedirectsInBackground : Bool = false
    private var prefetchLinks : Bool = false
    
    public var parentView : UIView?
    public var webView : UIWebView?
    public var webViewDelegate : UIWebViewDelegate?
    // currently followed AdUnit
    private var adUnitsToBeFollowed : [NativeAd] = [NativeAd]()

    private init(affiliateId : String?, delegate: NativeAdsConnectionProtocol?, parentView : UIView?) {
        super.init()
        self.affiliateId = affiliateId;
        self.delegate = delegate
        self.parentView = parentView
        self.followRedirectsInBackground = false
        self.webViewDelegate = self
    }
    
    private init(affiliateId : String?, delegate: NativeAdsConnectionProtocol?, parentView : UIView?, followRedirectsInBackground : Bool) {
        super.init()
        self.affiliateId = affiliateId;
        self.delegate = delegate
        self.parentView = parentView
        self.followRedirectsInBackground = followRedirectsInBackground
        self.webViewDelegate = self
    }

    private init(affiliateId : String?, delegate: NativeAdsConnectionProtocol?, parentView : UIView?, followRedirectsInBackground : Bool, webViewDelegate : UIWebViewDelegate?) {
        super.init()
        self.affiliateId = affiliateId;
        self.delegate = delegate
        self.parentView = parentView
        self.followRedirectsInBackground = followRedirectsInBackground
        self.webViewDelegate = webViewDelegate
    }

    
    public init(affiliateId : String?, delegate: NativeAdsConnectionProtocol?) {
        super.init()
        self.affiliateId = affiliateId;
        self.delegate = delegate
        self.followRedirectsInBackground = false
    }
    
    public func retrieveAds(limit: UInt){
        
        let nativeAdURL = getNativeAdsURL(self.affiliateId, limit: limit);
        print(nativeAdURL, terminator: "")
        
        if let url = NSURL(string: nativeAdURL) {
        
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
                if error != nil {
                    
                    self.delegate?.didRecieveError(error!)
                    
                } else {
                      var nativeAds: [NativeAd] = []
                    if let json: NSArray = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                      
                          json.filter({ ($0 as? NSDictionary) != nil}).forEach({ (element) -> () in
                            if let ad = NativeAd( adDictionary: element as! NSDictionary){
                              nativeAds.append(ad)
                              // disabled due to data problems caused by the "automated clicks"
                              if(self.prefetchLinks){
                                self.followRedirects(ad)
                              }
                            }
                            
                          })
                           
                        if nativeAds.count > 0 {
                            self.delegate?.didRecieveResults(nativeAds)
                        } else {
                            let userInfo = ["No ads available from server": NSLocalizedDescriptionKey]
                            let error = NSError(domain: "mobi.pocketmedia.nativeads", code: -1, userInfo: userInfo)
                            self.delegate?.didRecieveError(error)
                        }
                    }
                }
            }
        }
    }
    
    func provideIdentifierForAdvertisingIfAvailable() -> String? {
        if ASIdentifierManager.sharedManager().advertisingTrackingEnabled {
            return ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString ?? nil
        } else {
            return nil
        }
    }
    
    public func getNativeAdsURL(affiliateID: String?, limit: UInt) -> String {
        let token = provideIdentifierForAdvertisingIfAvailable()
        let baseUrl = betaModeEnabled ? NativeAdsConstants.NativeAds.baseURLBeta : NativeAdsConstants.NativeAds.baseURL;
        return baseUrl + "&os=ios&limit=\(limit)&version=\(NativeAdsConstants.Device.iosVersion)&model=\(NativeAdsConstants.Device.model)&token=\(token!)&affiliate_id=\(affiliateID!)"
    }

    
    
    
    public func followRedirects(adUnit : NativeAd?) -> Void{
        
        NSLog("Following redirects for \(adUnit!.clickURL)")
        self.adUnitsToBeFollowed.append(adUnit!)
        
        processQueue()
    }
    
    private func processQueue(){
        
        NSLog("'Queue process, size = \(self.adUnitsToBeFollowed.count)")
        if (self.adUnitsToBeFollowed.count > 0){
            startFollowingRedirects(self.adUnitsToBeFollowed[0])
        }//else, we wait for it to finish with the current one.
    }
    
    private func startFollowingRedirects(adUnit : NativeAd?){
        
        NSLog("Following redirects for \(adUnit!.clickURL)")
        
        if (webView == nil){
            webView = UIWebView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        }
        
        webView?.delegate = self
        webView?.hidden = true
        
        if ((webView) != nil){
            self.parentView!.addSubview(webView!)
        }
        
        let request : NSURLRequest = NSURLRequest(URL: (adUnit?.clickURL)!)
        webView?.loadRequest(request)
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        
        if (!self.adUnitsToBeFollowed.isEmpty){
            self.adUnitsToBeFollowed[0].clickURL = NSURL(string: (error?.userInfo["NSErrorFailingURLStringKey"])! as! String)
        
            NSLog("Final URL: \(self.adUnitsToBeFollowed[0].clickURL.absoluteString)")
            checkSimulatorURL()
            
            delegate?.didUpdateNativeAd(adUnitsToBeFollowed[0])
        
            self.adUnitsToBeFollowed.removeFirst()
            NSLog("'Queue element removed, size = \(self.adUnitsToBeFollowed.count)")

            
            processQueue()
            self.webView = nil
        }
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (!self.adUnitsToBeFollowed.isEmpty){
            self.adUnitsToBeFollowed[0].clickURL = request.URL
            NSLog("Updated URL: \(self.adUnitsToBeFollowed[0].clickURL.absoluteString)")
            checkSimulatorURL()
        }
        return urlIsLoadable(request.URL!)
    }
    
    private func urlIsLoadable(url : NSURL) -> Bool{
        return (url.scheme == "http" || url.scheme == "https")
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
    }
    
    private func checkSimulatorURL(){
        if (debugModeEnabled){
            if (Platform.isSimulator){
                
                if(self.adUnitsToBeFollowed[0].clickURL.scheme != "http" &&
                    self.adUnitsToBeFollowed[0].clickURL.scheme != "https"  ){
                
                self.adUnitsToBeFollowed[0].clickURL = NSURL(string: self.adUnitsToBeFollowed[0].clickURL.absoluteString.stringByReplacingOccurrencesOfString("itms-apps", withString: "http"))
                NSLog("URL is app store one and running in the simulator. Transforming to: \(self.adUnitsToBeFollowed[0].clickURL.absoluteString)")
                }
                
            }
        }
    }
    
    
}