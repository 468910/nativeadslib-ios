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
    // Because self.isViewLoaded is read only.
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
    //        subject = TestFullScreenBrowser(parent: nav)
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

    func testRunMethod() {
        class MockedFullScreenBrowser: TestFullScreenBrowser {
            var showCalled = false
            override func show(animate: Bool = true) {
                showCalled = true
            }

            var hideExpectation: XCTestExpectation?
            override func hide(animate: Bool = true) {
                guard let expectation = hideExpectation else {
                    XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                expectation.fulfill()
            }
        }
        // Setup
        subject = MockedFullScreenBrowser()
        let mockedSubject = subject as! MockedFullScreenBrowser
        let webview = UIWebView(frame: CGRect.init(x: 0, y: 0, width: 112, height: 911))

        // Not ready
        subject?.run()
        XCTAssertTrue(mockedSubject.showCalled, "Show should be called.")

        // Setup our call expections
        let expectation = self.expectation(description: "Hide should have been caled()")
        mockedSubject.hideExpectation = expectation

        // Ready no ad.
        subject?.webView = webview
        subject?.run()
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }

        // Ready ad.
        class testDelegate: NativeAdOpenerDelegate {
            public var openerStartedCalled = false
            func openerStarted() {
                openerStartedCalled = true
            }

            func openerStopped() {}
        }

        class webDelegate: NativeAdsWebviewDelegate {
            init(delegate: NativeAdsWebviewRedirectionsDelegate) {
                super.init(delegate: delegate, webView: UIWebView())
            }

            public var loadUrlCalled = false
            public override func loadUrl(_ nativeAdUnit: NativeAd) {
                loadUrlCalled = true
            }
        }

        subject?.delegate = testDelegate()
        subject?.webView = webview
        subject?.webViewDelegate = webDelegate(delegate: self.subject!)
        subject?.load(ad!)
        XCTAssertTrue((subject?.delegate as! testDelegate).openerStartedCalled, "Delegate should be informec once we start loading")
        XCTAssertTrue((subject?.webViewDelegate as! webDelegate).loadUrlCalled, "web delegate should be informec to start loading an url")
    }
}
