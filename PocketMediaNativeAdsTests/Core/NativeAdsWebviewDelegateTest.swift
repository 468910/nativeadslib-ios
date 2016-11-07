//
//  NativeAdsWebviewDelegateTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 12/09/16.
//
//

import XCTest

@testable import PocketMediaNativeAds

class MockNativeAdsWebviewRedirectionsDelegate: NativeAdsWebviewRedirectionsDelegate {
    internal var didOpenBrowserCalled: Bool = false
    @objc
    func didOpenBrowser(_ url: URL) {
        didOpenBrowserCalled = true
    }
}

class MockUIWebView: UIWebView {
    var loadRequestCalled: Bool = false
    override func loadRequest(_ request: URLRequest) {
        loadRequestCalled = true
    }
}

class SpyWebViewDelegate: NSObject, UIWebViewDelegate {
    var finishLoadExpectation: XCTestExpectation?

    @objc
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let expectation = finishLoadExpectation else {
            XCTFail("SpyWebDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        expectation.fulfill()
    }
}

// If we pass certain errors it should return and not continue
class MockNativeAdsWebviewDelegate: NativeAdsWebviewDelegate {
    var checkIfAppStoreUrlCalled: Bool = false
    var returnCheckIfAppStoreUrl: Bool = false
    override func checkIfAppStoreUrl(_ request: URLRequest) -> Bool {
        checkIfAppStoreUrlCalled = true
        return returnCheckIfAppStoreUrl
    }

    var openSystemBrowserCalled: Bool = false
    override func openSystemBrowser(_ url: URL) {
        openSystemBrowserCalled = true
    }

    var notifyServerOfFalseRedirectionCalled: Bool = false
    override func notifyServerOfFalseRedirection(_ session: URLSession = URLSession.shared) {
        notifyServerOfFalseRedirectionCalled = true
    }
}

class NativeAdsWebviewDelegateTest: XCTestCase {

    var subject: NativeAdsWebviewDelegate?
    var webview: MockUIWebView?
    var delegate: MockNativeAdsWebviewRedirectionsDelegate?

    override func setUp() {
        webview = MockUIWebView()
        delegate = MockNativeAdsWebviewRedirectionsDelegate()

        subject = NativeAdsWebviewDelegate(delegate: delegate, webView: webview!)
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWebViewFailError() {
        // If we pass certain errors it should return and not continue
        // NSURLErrorCancelled
        subject = MockNativeAdsWebviewDelegate(delegate: delegate, webView: webview!)
        let mockedSubject = subject as! MockNativeAdsWebviewDelegate

        var error: NSError
        error = NSError(domain: "unit.tests", code: NSURLErrorCancelled, userInfo: nil)
        subject?.webView(webview!, didFailLoadWithError: error)
        XCTAssert(mockedSubject.checkIfAppStoreUrlCalled == false, "checkIfAppStoreUrl should not have been called. Since we sent a error along.")
        mockedSubject.checkIfAppStoreUrlCalled = false

        // Frame Load Interrupted
        error = NSError(domain: "unit.tests", code: 102, userInfo: nil)
        subject?.webView(webview!, didFailLoadWithError: error)
        XCTAssert(mockedSubject.checkIfAppStoreUrlCalled == false, "checkIfAppStoreUrl should not have been called. Since we sent a error along.")
        mockedSubject.checkIfAppStoreUrlCalled = false
    }

    //    func testWebViewFailSuccess() {
    //        // If we pass certain errors it should return and not continue
    //        subject = MockNativeAdsWebviewDelegate(delegate: delegate, webView: webview!)
    //        let mockedSubject = subject as! MockNativeAdsWebviewDelegate
    //
    //        let spyWebViewDelegate = SpyWebViewDelegate()
    //        spyWebViewDelegate.finishLoadExpectation = expectation(description: "Wait for request attribute")
    //        webview?.delegate = spyWebViewDelegate
    //        webview?.loadHTMLString("<html>test</html>", baseURL: URL(string: "http://google.co.uk")!)
    //
    //        // wait for webview.request
    //        self.waitForExpectations(timeout: 5) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //
    //            mockedSubject.returnCheckIfAppStoreUrl = true
    //            XCTAssert(self.webview != nil && self.webview!.request != nil, "Webview request shouldn't be nil")
    //
    //            self.subject?.webView(self.webview!, didFailLoadWithError: NSError(coder: NSCoder())!)
    //            XCTAssert(mockedSubject.checkIfAppStoreUrlCalled == true, "checkIfAppStoreUrl should have called checkIfAppStoreUrl")
    //            XCTAssert(mockedSubject.notifyServerOfFalseRedirectionCalled == false, "checkIfAppStoreUrl should have called notifyServerOfFalseRedirectionCalled")
    //        }
    //    }

    //
    //    func testWebViewFailBadUrl() {
    //        subject = MockNativeAdsWebviewDelegate(delegate: delegate, webView: webview!)
    //        let mockedSubject = subject as! MockNativeAdsWebviewDelegate
    //
    //        let spyWebViewDelegate = SpyWebViewDelegate()
    //        spyWebViewDelegate.finishLoadExpectation = expectationWithDescription("Wait for request attribute")
    //        webview?.delegate = spyWebViewDelegate
    //        webview?.loadHTMLString("<html>test</html>", baseURL: NSURL(string: "http://google.co.uk")!)
    //
    //        //wait for webview.request
    //        self.waitForExpectationsWithTimeout(5) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //
    //            XCTAssert(self.webview != nil && self.webview!.request != nil, "Webview request shouldn't be nil")
    //
    //            //It should fail
    //            self.subject?.loadStatusCheckTimer = nil
    //            self.subject?.webView(self.webview!, didFailLoadWithError: NSError(coder: NSCoder())!)
    //
    //            XCTAssert(mockedSubject.checkIfAppStoreUrlCalled == true, "checkIfAppStoreUrl should have called checkIfAppStoreUrl")
    //            XCTAssert(mockedSubject.openSystemBrowserCalled == false, "checkIfAppStoreUrl should NOT have called openSystemBrowserCalled")
    //            XCTAssert(mockedSubject.notifyServerOfFalseRedirectionCalled == true, "checkIfAppStoreUrl should have called notifyServerOfFalseRedirectionCalled")
    //        }
    //    }

    func testWebViewSuccess() {
        subject = MockNativeAdsWebviewDelegate(delegate: delegate, webView: webview!)
        let mockedSubject = subject as! MockNativeAdsWebviewDelegate

        let spyWebViewDelegate = SpyWebViewDelegate()
        spyWebViewDelegate.finishLoadExpectation = expectation(description: "Wait for request attribute")
        webview?.delegate = spyWebViewDelegate
        webview?.loadHTMLString("<html>test</html>", baseURL: URL(string: "https://itunes.apple.com/us/app/2048/id839720238?mt=8")!)

        // wait for webview.request
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            XCTAssert(self.webview != nil && self.webview!.request != nil, "Webview request shouldn't be nil")

            // It should succeed
            mockedSubject.returnCheckIfAppStoreUrl = true

            var result = self.subject?.webView(self.webview!, shouldStartLoadWith: URLRequest(url: URL(string: "https://itunes.apple.com/us/app/2048/id839720238?mt=8")!), navigationType: UIWebViewNavigationType.linkClicked)

            XCTAssert(self.subject?.loadStatusCheckTimer == nil, "loadStatusCheckTimer should be nil")

            XCTAssert(mockedSubject.checkIfAppStoreUrlCalled == true, "checkIfAppStoreUrl should have called checkIfAppStoreUrl")
            XCTAssert(mockedSubject.openSystemBrowserCalled == true, "checkIfAppStoreUrl should have called openSystemBrowserCalled")
            XCTAssert(result! == false, "webView should return false")

            mockedSubject.returnCheckIfAppStoreUrl = false
            result = self.subject?.webView(self.webview!, shouldStartLoadWith: URLRequest(url: URL(string: "https://itunes.apple.com/us/app/2048/id839720238?mt=8")!), navigationType: UIWebViewNavigationType.linkClicked)
            XCTAssert(result!, "webView should return true since its not done yet.")
        }
    }

    func testCheckIfAppStoreUrl() {
        XCTAssert(subject!.checkIfAppStoreUrl(URLRequest(url: URL(string: "https://itunes.apple.com/us/app/2048/id839720238?mt=8")!)), "A valid itunes link")
        XCTAssert(!subject!.checkIfAppStoreUrl(URLRequest(url: URL(string: "https://itunes.apple123.com/us/app/2048/id839720238?mt=8")!)), "A invalid itunes link")
        // XCTAssert(!subject!.checkIfAppStoreUrl(NSURLRequest(URL: NSURL(string: "https://itunes.apple.com/us/id000?mt=8")!)), "A invalid itunes link")
        XCTAssert(!subject!.checkIfAppStoreUrl(URLRequest(url: URL(string: "http://pocketmedia.mobi")!)), "A invalid link")
        XCTAssert(subject!.checkIfAppStoreUrl(URLRequest(url: URL(string: "itms-apps://itunes.com/app/123123")!)), "A valid itms link")
        XCTAssert(subject!.checkIfAppStoreUrl(URLRequest(url: URL(string: "itms://app/123123")!)), "A valid itms link")
    }

    func testLoadUrl() {
        let data = [
            "campaign_name": "tests",
            "click_url": "http://PocketMedia.mobi/lovely/tests",
            "campaign_description": "",
            "id": "123",
            "default_icon": "http://google.co.uk",
            "images": NSDictionary(),
        ] as [String: Any]
        do {
            let ad = try NativeAd(adDictionary: data as NSDictionary, adPlacementToken: "test")
            subject?.loadUrl(ad)
            XCTAssert(webview!.loadRequestCalled, "loadRequest should have been called")
        } catch {
        }
    }

    func testOpenSystemBrowser() {
        // Is not testable due to: There can only be one UIApplication instance.
        // http://stackoverflow.com/questions/3265969/how-to-mock-property-internal-value-of-uiapplication
        //        class MockUIApplication : UIApplication {
        //            var canOpenURLCalled: Bool = false
        //            var openURLCalled: Bool = false
        //
        //            override func canOpenURL(url: NSURL) -> Bool {
        //                canOpenURLCalled = true
        //                return true
        //            }
        //
        //            override func openURL(url: NSURL) -> Bool {
        //                openURLCalled = true
        //                return true
        //            }
        //
        //        }
        //        let app = MockUIApplication()
        //        subject?.openSystemBrowser(NSURL(string: "http://google.co.uk")!, application: app)
        //
        //        XCTAssert(app.canOpenURLCalled, "CanOpenUrl should have been called.")
        //        XCTAssert(app.openURLCalled, "openURL should have been called.")

        subject?.openSystemBrowser(URL(string: "http://google.co.uk")!)
        XCTAssert((delegate?.didOpenBrowserCalled)!, "openSystemBrowser should call didOpenBrowserCalled with the final url")
    }

    func testNotifyServerOfFalseRedirection() {

        class MockNSURLSessionDownloadTask: URLSessionDownloadTask {

            var resumeExpectation: XCTestExpectation?
            override func resume() {
                guard let expectation = resumeExpectation else {
                    XCTFail("SpyWebDelegate was not setup correctly. Missing XCTExpectation reference")
                    return
                }
                expectation.fulfill()
            }
        }

        class MockSession: URLSession {

            var downloadTaskWithRequestCalled: Bool = false
            var downloadTask: MockNSURLSessionDownloadTask = MockNSURLSessionDownloadTask()
            override func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
                downloadTaskWithRequestCalled = true

                let url = URL(string: "http://google.co.uk/")!
                completionHandler(url, URLResponse(url: url, mimeType: "", expectedContentLength: 0, textEncodingName: ""), nil)
                return downloadTask
            }
        }

        let session = MockSession()

        session.downloadTask.resumeExpectation = expectation(description: "Resume should be called")
        subject!.notifyServerOfFalseRedirection(session)

        // wait for webview.request
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssert(session.downloadTaskWithRequestCalled, "downloadTaskWithRequest should have been called")
        }
    }

    func testWebViewDidStartLoad() {
        let parentView = UIWebView()
        subject!.webViewDidStartLoad(parentView)

        var foundView: UIView? = nil
        for subview in (parentView.subviews) {
            if subview.isKind(of: UIView.self) && subview.frame.height == 80 && subview.frame.width == 80 {
                foundView = subview
                break
            }
        }

        XCTAssert(subject!.loadingView === foundView, "It should add a loading view")
    }
}
