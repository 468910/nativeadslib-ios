//
//  FullscreenBrowserTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//
import XCTest
import Foundation
import UIKit

@testable import PocketMediaNativeAds

public class MockNativeAd: NativeAd {
    private (set) var openAdUrlInForegroundCalled: Bool = false
    
    public override func openAdUrlInForeground() {
        openAdUrlInForegroundCalled = true
    }
    
}

class FullscreenBrowserTest: XCTestCase {
    
    var subject : FullscreenBrowser?
    var data:[String:String] = [:]
    
    override func setUp() {
        
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let viewController = navigationController.topViewController
        UIApplication.sharedApplication().keyWindow!.rootViewController = viewController
        
        // this is the line responsible for the race condition
        NSRunLoop.mainRunLoop().runUntilDate(NSDate())
        
        subject = FullscreenBrowser(parentViewController: viewController!)
        
        data = [
            "campaign_name": "tests",
            "click_url": "http://PocketMedia.mobi/lovely/tests",
            "campaign_description": "",
            "id": "123",
            "default_icon": "http://google.co.uk"
        ]
        
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testSetupWebView() {
//        do {
//            let ad = try MockNativeAd(adDictionary: data, adPlacementToken: "test")
//            subject?.load(ad)
//        } catch {
//            XCTFail("MockNativeAd is throwing an ")
//        }
//    }
    
}