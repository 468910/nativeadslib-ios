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

class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: true)
    }
}

class MockedNativeAdsWebviewDelegate: NativeAdsWebviewDelegate {

    var loadUrlExpectation: XCTestExpectation?
    var loadUrlErrorResult: Bool? = .none
    internal var sentNativeAdUnit: NativeAd?

    init(delegate: NativeAdsWebviewRedirectionsDelegate) {
        let webview = UIWebView(frame: CGRect.init(x: 0, y: 0, width: 112, height: 911))
        super.init(delegate: delegate, webView: webview)
    }

    @objc
    internal override func loadUrl(_ nativeAdUnit: NativeAd) {
        guard let expectation = loadUrlExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        loadUrlErrorResult = true
        expectation.fulfill()

        self.sentNativeAdUnit = nativeAdUnit
    }
}

class TestFullScreenBrowser: FullScreenBrowser {
    //Because self.isViewLoaded is read only.
    override func ready() -> Bool {
        return self.webView != nil
    }
}

class FullScreenBrowserTest: XCTestCase {

    var subject: TestFullScreenBrowser?
    var ad: NativeAd?

    override func setUp() {
        self.subject = TestFullScreenBrowser()
        self.ad = testHelpers.getNativeAd()
    }

    func testInit() {
        // The subject. But some methods overriden
        class MockedFullScreenBrowser: TestFullScreenBrowser {
            public let testRootView = mockedUIViewController()

            override func getRootView() -> UIViewController? {
                return testRootView
            }
        }
        subject = MockedFullScreenBrowser()
        let mockedSubject = subject as! MockedFullScreenBrowser
        XCTAssertTrue(mockedSubject.testRootView == mockedSubject.parentController, "Because there isn't a navigation controller it should use the rootView.")
    }

    //    func testInitWithNav() {
    //        let nav = MockNavigationController(rootViewController: UIViewController())
    //        subject = MockedFullScreenBrowser(parent: nav)
    //
    //        XCTAssertTrue(nav == subject?.parentController, "Because there is a navigation controller it should not use the root one.")
    //    }

    func testViewWillDisappear() {
        class testDelegate: NativeAdOpenerDelegate {
            func openerStarted() {}

            public var openerStoppedCalled = false
            func openerStopped() {
                openerStoppedCalled = true
            }
        }

        class webDelegate: NativeAdsWebviewDelegate {
            init(delegate: NativeAdsWebviewRedirectionsDelegate) {
                super.init(delegate: delegate, webView: UIWebView())
            }

            public var stopCalled = false
            public override func stop() {
                stopCalled = true
            }
        }

        subject?.delegate = testDelegate()
        subject?.webViewDelegate = webDelegate(delegate: self.subject!)
        subject?.viewWillDisappear(false)

        XCTAssertTrue((subject?.webViewDelegate as! webDelegate).stopCalled, "Should've instructed the webdelegate to stop.")
        XCTAssertTrue((subject?.delegate as! testDelegate).openerStoppedCalled)
    }

    func testViewDidLoad() {
        class MockedFullScreenBrowser: TestFullScreenBrowser {

            var setupCloseButtonLoaded = false
            override func setupCloseButton() {
                setupCloseButtonLoaded = true
            }

            var setupWebViewLoaded = false
            override func setupWebView(delegate: NativeAdsWebviewDelegate? = nil) {
                setupWebViewLoaded = true
            }

            var runLoaded = false
            override func run() {
                runLoaded = true
            }
        }
        subject = MockedFullScreenBrowser()
        let mockedSubject = subject as! MockedFullScreenBrowser
        subject?.viewDidLoad()
        XCTAssertTrue(mockedSubject.setupCloseButtonLoaded, "It should've called this method")
        XCTAssertTrue(mockedSubject.setupWebViewLoaded, "It should've called this method")
        XCTAssertTrue(mockedSubject.runLoaded, "It should've called this method")
    }

    func testSetupWebView() {
        // Setup
        let webview = UIWebView(frame: CGRect.init(x: 0, y: 0, width: 112, height: 911))
        let delegate = NativeAdsWebviewDelegate(delegate: self.subject!, webView: webview)

        // Call
        // Without a webview
        self.subject?.setupWebView()
        XCTAssertNil(self.subject?.webView?.delegate)

        self.subject?.webView = webview
        // Passed along delegate
        self.subject?.setupWebView(delegate: delegate)
        XCTAssertTrue(self.subject?.webView?.delegate === delegate, "We specified a delegate. Use that one!")

        // No delegate.
        self.subject?.setupWebView()
        XCTAssertNotNil(self.subject?.webView?.delegate)
        XCTAssertTrue(self.subject?.webView?.delegate !== delegate)
    }

    //    func runLoadTests(_ runWithNavigationController: Bool) {
    //        do {
    //
    //            // Set our mocked NativeAdsWebviewDelegate
    //            let mockedNativeAdsWebviewDelegate = MockedNativeAdsWebviewDelegate(delegate: subject!)
    //
    //            subject!.setupWebView(delegate: mockedNativeAdsWebviewDelegate)
    //
    //            // Setup our call expections
    //            let expectation = self.expectation(description: "loadUrl should get called from show()")
    //            mockedNativeAdsWebviewDelegate.loadUrlExpectation = expectation
    //            mockedNativeAdsWebviewDelegate.loadUrlErrorResult = false
    //
    //            // Call the load function with our mocked ad.
    //            subject?.load(ad!)
    //
    //            // Check if loadUrl in the NativeAdsWebviewDelegate was called
    //            waitForExpectations(timeout: 1) { error in
    //
    //                if let error = error {
    //                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //                }
    //
    //                guard let result = mockedNativeAdsWebviewDelegate.loadUrlErrorResult else {
    //                    XCTFail("Expected delegate to be called")
    //                    return
    //                }
    //
    //                XCTAssert(mockedNativeAdsWebviewDelegate.sentNativeAdUnit == self.ad, "The ad that was sent should've been loaded")
    //            }
    //
    //        } catch {
    //            XCTFail("MockNativeAd is throwing an ")
    //        }
    //    }
}
