//
//  NativeAdsRequestTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 06/09/16.
//
//

import XCTest
import AdSupport

@testable import PocketMediaNativeAds

class SpyDelegate: NativeAdsConnectionDelegate {

    var didReceiveErrorExpectation: XCTestExpectation?
    var didReceiveErrorResult: Bool? = .none

    var didReceiveResultsExpectation: XCTestExpectation?
    var didReceiveResultsResult: Bool? = .none

    /**
     This method is invoked whenever while retrieving NativeAds an error has occured
     */
    @objc
    func didReceiveError(_ error: Error) {
        print("didReceiveError: \(error)")
        guard let expectation = didReceiveErrorExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        didReceiveErrorResult = true
        expectation.fulfill()
    }

    /**
     This method allows the delegate to receive a collection of NativeAds after making an NativeAdRequest.
     - nativeAds: Collection of NativeAds received after making a NativeAdRequest
     */
    @objc
    func didReceiveResults(_ nativeAds: [NativeAd]) {
        guard let expectation = didReceiveResultsExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        didReceiveResultsResult = true
        expectation.fulfill()
    }
}

class MockedNSURLSessionDataTask: URLSessionDataTask {
    var resumeCalled: Bool? = false
    override func resume() {
        resumeCalled = true
    }
}

class MockURLSession: URLSession {
    fileprivate(set) var lastURL: URL?
    var task: MockedNSURLSessionDataTask = MockedNSURLSessionDataTask()

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void)
        -> URLSessionDataTask {
            lastURL = url
            return task
        }
}

class NativeAdsRequestTest: XCTestCase {

    var testData: Data!

    override func setUp() {
        super.setUp()
        if let file = Bundle(for: NativeAdsRequestTest.self).path(forResource: "Tests", ofType: "json") {
            self.testData = try? Data(contentsOf: URL(fileURLWithPath: file))
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRetrieveAds() {
        let delegate = SpyDelegate()
        let session = MockURLSession()
        let nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: delegate, session: session)
        nativeAdsrequest.retrieveAds(10)
        let expected = nativeAdsrequest.getNativeAdsURL("test", limit: 10, imageType: EImageType.allImages)

        XCTAssert(session.task.resumeCalled!, "NativeAdsRequest should've called resume to actually do the network request.§")

        if let expectedUrl = URL(string: expected) {
            XCTAssert(session.lastURL! == expectedUrl)
        } else {
            XCTFail("Couldn't get the expected url")
        }
    }

    func testReceivedAdsError() {
        let delegate = SpyDelegate()

        // Pass an error
        var expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveError method due to the fact that th ereceivedAds method receiving an error")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false

        let nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: delegate)

        nativeAdsrequest.receivedAds(testData, response: nil, error: NSError(domain: "Example", code: 0, userInfo: nil))

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }

        // Data is nil
        expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveError method due to the fact that the data sent is a nil value.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false

        nativeAdsrequest.receivedAds(nil, response: nil, error: nil)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }

        // Invalid json
        expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveError method due to the fact that the data sent is not json.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false

        nativeAdsrequest.receivedAds("This is not a proper response. Not json ;(".data(using: String.Encoding.utf8), response: nil, error: nil)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }
        // Incorrect
        expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveError method due to the fact that the data sent is incomplete or incorrect json.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false

        nativeAdsrequest.receivedAds("[{}]".data(using: String.Encoding.utf8), response: nil, error: nil)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }

        // Zero ads
        expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveError method due to the fact that the receivedAds has 0 offers to send back.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false

        nativeAdsrequest.receivedAds("[]".data(using: String.Encoding.utf8), response: nil, error: nil)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }
    }

    func testReceivedSuccess() {
        let delegate = SpyDelegate()

        let expectation = self.expectation(description: "NativeAdsRequest calls the delegate didReceiveResults method due to the fact that it has received a proper response back from the server.")
        delegate.didReceiveResultsExpectation = expectation
        delegate.didReceiveResultsResult = false

        let nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: delegate)

        nativeAdsrequest.receivedAds(testData, response: nil, error: nil)

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = delegate.didReceiveResultsResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }
    }

    func testGetNativeAdsURL() {
        var nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: nil)
        let placement_key = "test123"
        var url = nativeAdsrequest.getNativeAdsURL(placement_key, limit: 123, imageType: EImageType.banner)

        if let value = getQueryStringParameter(url, param: "output") {

            if value != "json" {
                XCTFail("output should be json")
            }

        } else {
            XCTFail("output parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "os") {

            if value != "ios" {
                XCTFail("os should be ios")
            }

        } else {
            XCTFail("os parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "limit") {

            if Int(value) != 123 {
                XCTFail("limit should be 123")
            }

        } else {
            XCTFail("limit parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "version") {

            if Float(value) == nil {
                XCTFail("version should be a number")
            }

        } else {
            XCTFail("version parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "model") {

            let expected = UIDevice.current.model.characters.split { $0 == " " }.map { String($0) }[0]
            if value != expected {
                XCTFail("model should be a iPhone")
            }

        } else {
            XCTFail("model parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "token") {

            let expected = ASIdentifierManager.shared().advertisingIdentifier?.uuidString

            if value != expected {
                XCTFail("token should be the advertisingIdentifier of the phone")
            }

        } else {
            XCTFail("token parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "placement_key") {

            if value != placement_key {
                XCTFail("placement_key should the test value sent along as a parameter.")
            }

        } else {
            XCTFail("placement_key parameter is not defined")
        }

        if let value = getQueryStringParameter(url, param: "image_type") {

            if value != String(describing: EImageType.banner) {
                XCTFail("placement_key should the test value sent along as a parameter.")
            }

        } else {
            XCTFail("image_type parameter is not defined")
        }

        nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: nil, advertisingTrackingEnabled: false)
        url = nativeAdsrequest.getNativeAdsURL(placement_key, limit: 123, imageType: EImageType.allImages)

        if let value = getQueryStringParameter(url, param: "optout") {

            if Int(value) != 1 {
                XCTFail("optout should be set to 1 if advertisingTrackingEnabled is set to false.")
            }

        } else {
            XCTFail("optout parameter is not defined")
        }
    }
}

func getQueryStringParameter(_ url: String?, param: String) -> String? {
    let url = url,
        urlComponents = URLComponents(string: url!),
        queryItems = urlComponents!.queryItems!
    return queryItems.filter({ item in item.name == param }).first?.value!
}
