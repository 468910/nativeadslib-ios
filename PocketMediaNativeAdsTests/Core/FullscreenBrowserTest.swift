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

class MockNavigationController: UINavigationController {
    
    var pushedViewController: UIViewController?
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: true)
    }
}

class MockedNativeAdsWebviewDelegate : NativeAdsWebviewDelegate {
    
    var loadUrlExpectation: XCTestExpectation?
    var loadUrlErrorResult: Bool? = .None
    internal var sentNativeAdUnit: NativeAd?
    
    @objc
    internal override func loadUrl(nativeAdUnit: NativeAd) {
        guard let expectation = loadUrlExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        loadUrlErrorResult = true
        expectation.fulfill()
        
        self.sentNativeAdUnit = nativeAdUnit
    }
}

class MockedUIViewController: UIViewController {
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        completion!()
    }
}

class MockedFullscreenBrowser: FullscreenBrowser {
    internal var dismissViewControllerAnimatedExpectation: XCTestExpectation?
    internal var dismissViewControllerAnimatedResult: Bool? = .None
    
    internal override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        guard let expectation = dismissViewControllerAnimatedExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        dismissViewControllerAnimatedResult = true
        expectation.fulfill()
    }
}

class FullscreenBrowserTest: XCTestCase {

	var subject: FullscreenBrowser?
    var viewController: UIViewController?
	var data: [String: String] = [:]

	override func setUp() {

		viewController = MockedUIViewController()
        viewController?.view = UIWebView(frame: CGRect.init(
            x: 0,
            y: 0,
            width: 112,
            height: 911
            )
        )
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

	func testSetupWebView() {
        XCTAssert(subject?.webView != nil, "Webview should get initialized.")
        XCTAssert(subject?.view! ==  subject?.webView, "view should be the same as webview.")
        XCTAssert(viewController!.view.bounds.width == subject?.view!.bounds.width, "Width should be set to the width of the viewController")
        XCTAssert(viewController!.view.bounds.height == subject?.view!.bounds.height, "Height should be set to the width of the viewController")
        XCTAssert(subject!.webViewDelegate != nil, "webViewDelegate should be set.")
        XCTAssert(subject!.webView!.delegate === subject?.webViewDelegate, "the webview delegate should be set to the webViewDelegate.")
	}
    
    func testSetupWithNavigationController() {
        viewController = UIViewController()
        viewController?.view = UIWebView(frame: CGRect.init(
            x: 0,
            y: 0,
            width: 0,
            height: 0
            )
        )
        
        let nav = MockNavigationController(rootViewController: viewController!)
        subject = FullscreenBrowser(parentViewController: viewController!)
        
        XCTAssert(nav.pushedViewController is FullscreenBrowser, "The initializer should've pushed the viewController.")
        XCTAssert(subject?.webView != nil, "Webview should get initialized.")
        XCTAssert(subject?.view! ==  subject?.webView, "view should be the same as webview.")
        XCTAssert(UIScreen.mainScreen().bounds.width == subject?.view!.bounds.width, "Width should be set to the width of the viewController")
        XCTAssert(UIScreen.mainScreen().bounds.height == subject?.view!.bounds.height, "Height should be set to the width of the viewController")
        XCTAssert(subject!.webViewDelegate != nil, "webViewDelegate should be set.")
        XCTAssert(subject!.webView!.delegate === subject?.webViewDelegate, "the webview delegate should be set to the webViewDelegate.")
    }

    func runLoadTests(runWithNavigationController:Bool) {
		do {
			let ad = try MockNativeAd(adDictionary: data, adPlacementToken: "test")
            
            //Set our mocked NativeAdsWebviewDelegate
            let mockedNativeAdsWebviewDelegate = MockedNativeAdsWebviewDelegate(delegate: subject, webView: subject!.webView!)
            subject!.setupWebView(0, height: 0, delegate: mockedNativeAdsWebviewDelegate)
            
            //Setup our call expections
            let expectation = expectationWithDescription("loadUrl should get called from show()")
            mockedNativeAdsWebviewDelegate.loadUrlExpectation = expectation
            mockedNativeAdsWebviewDelegate.loadUrlErrorResult = false
        
            //sleep(10)
            
            //Call the load function with our mocked ad.
			subject?.load(ad)
            
            //Check if the close button was added
            var found = false
            for subview in (subject?.view.subviews)! {
                if subview.isKindOfClass(UIButton) {
                    found = true
                }
            }
            
            if !runWithNavigationController {
                XCTAssert(found, "It should add a close button")
            }
            
            //Check if loadUrl in the NativeAdsWebviewDelegate was called
            waitForExpectationsWithTimeout(1) { error in
                
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                }
                
                guard let result = mockedNativeAdsWebviewDelegate.loadUrlErrorResult else {
                    XCTFail("Expected delegate to be called")
                    return
                }
                
                XCTAssert(mockedNativeAdsWebviewDelegate.sentNativeAdUnit == ad, "The ad that was sent should've been loaded")
            }
            
		} catch {
			XCTFail("MockNativeAd is throwing an ")
		}
	}
    
    func testLoadWithNavigationController() {
        //Create a non mocked UIViewController. We don't want to use the mocked presentViewController()
        viewController = UIViewController()
        viewController?.view = UIWebView(frame: CGRect.init(
            x: 0,
            y: 0,
            width: 0,
            height: 0
            )
        )
        let nav = MockNavigationController(rootViewController: viewController!)
        subject = FullscreenBrowser(parentViewController: viewController!)
        XCTAssert(nav.pushedViewController is FullscreenBrowser, "The initializer should've pushed the viewController.")
        
        runLoadTests(true)
    }
    
    func testLoadWithoutNavigationController() {
        runLoadTests(false)
    }

    func testFatalInit() {
        expectFatalError("init(coder:) has not been implemented", testcase: {
            FullscreenBrowser(coder: NSCoder())
        })
    }
    
    func testDidOpenBrowser() {
        //Expected outcome is that the pushedViewController is nolonger FullScreenBrowser
        let nav = MockNavigationController(rootViewController: viewController!)
        subject = FullscreenBrowser(parentViewController: viewController!)
        
        XCTAssert(nav.pushedViewController is FullscreenBrowser, "The initializer should've pushed the viewController.")
        subject?.didOpenBrowser(NSURL(string: "http://google.co.uk")!)
        XCTAssert(nav.pushedViewController is FullscreenBrowser, "didOpenBrowser should've popped the viewController.")
    }
    
    func testDidOpenBrowserWithoutNavigationController() {
        //Expected outcome is that the pushedViewController is nolonger FullScreenBrowser
        viewController = UIViewController()
        viewController?.view = UIWebView(frame: CGRect.init(
            x: 0,
            y: 0,
            width: 112,
            height: 911
            )
        )
        subject = MockedFullscreenBrowser(parentViewController: viewController!)
        
        //Setup our call expections
        let expectation = expectationWithDescription("didOpenBrowser should've eventually called dismissViewControllerAnimated()")
        
        (subject as! MockedFullscreenBrowser).dismissViewControllerAnimatedExpectation = expectation
        (subject as! MockedFullscreenBrowser).dismissViewControllerAnimatedResult = false
        
        subject?.didOpenBrowser(NSURL(string: "http://google.co.uk")!)
        
        //Check if loadUrl in the NativeAdsWebviewDelegate was called
        waitForExpectationsWithTimeout(1) { error in
            
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = (self.subject as! MockedFullscreenBrowser).dismissViewControllerAnimatedResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssert(true)
        }
        
    }

    func testWillMoveToParentViewController() {
        class MockedUIWebView : UIWebView {
            internal var stopLoadingCalled: Bool = false
            override func stopLoading() {
                self.stopLoadingCalled = true
            }
        }
        subject?.webView = MockedUIWebView()
        subject?.willMoveToParentViewController(nil)
        XCTAssert((subject?.webView as! MockedUIWebView).stopLoadingCalled, "willMoveToParentViewController should've called stopLoadingCalled on the webview.")
    }
}