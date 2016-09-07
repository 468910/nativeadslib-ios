//
//  NativeAdsRequestTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 06/09/16.
//
//

import XCTest

@testable import PocketMediaNativeAds

class SpyDelegate: NativeAdsConnectionDelegate {
    
    var didReceiveErrorExpectation: XCTestExpectation?
    var didReceiveErrorResult: Bool? = .None
    
    var didReceiveResultsExpectation: XCTestExpectation?
    var didReceiveResultsResult: Bool? = .None

    /**
     This method is invoked whenever while retrieving NativeAds an error has occured
     */
    @objc
    func didReceiveError(error: NSError) {
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
    func didReceiveResults(nativeAds: [NativeAd]) {
        guard let expectation = didReceiveResultsExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        didReceiveResultsResult = true
        expectation.fulfill()
    }
    
    /**
     Optional method, used in conjunction with the 'followRedirectsInBackground'.
     - adUnit: flag enabled in the NativeAdsRequest.
     */
    @objc func didUpdateNativeAd(adUnit : NativeAd) {
        
    }
    
}

class NativeAdsRequestTest: XCTestCase {
    
    var testData: NSData!
    
    override func setUp() {
        super.setUp()
        if let file = NSBundle(forClass:NativeAdsRequestTest.self).pathForResource("Tests", ofType: "json") {
            self.testData = NSData(contentsOfFile: file)
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReceivedAdsError() {
        let delegate = SpyDelegate()
        
        //Pass an error
        var expectation = expectationWithDescription("NativeAdsRequest calls the delegate didReceiveError method due to the fact that th ereceivedAds method receiving an error")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false
        
        let nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: delegate)
        
        nativeAdsrequest.receivedAds(testData, response: nil, error: NSError(domain: "Example", code: 0, userInfo: nil))
        
        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssertTrue(result)
        }
        
        //Data is nil
        expectation = expectationWithDescription("NativeAdsRequest calls the delegate didReceiveError method due to the fact that the data sent is a nil value.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false
        
        nativeAdsrequest.receivedAds(nil, response: nil, error: nil)
        
        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssertTrue(result)
        }
        
        //Invalid json
        expectation = expectationWithDescription("NativeAdsRequest calls the delegate didReceiveError method due to the fact that the data sent is not json.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false
        
        nativeAdsrequest.receivedAds("This is not a proper response. Not json ;(".dataUsingEncoding(NSUTF8StringEncoding), response: nil, error: nil)
        
        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = delegate.didReceiveErrorResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssertTrue(result)
        }
        
        
        //Zero ads
        expectation = expectationWithDescription("NativeAdsRequest calls the delegate didReceiveError method due to the fact that the receivedAds has 0 offers to send back.")
        delegate.didReceiveErrorExpectation = expectation
        delegate.didReceiveErrorResult = false
        
        nativeAdsrequest.receivedAds("[]".dataUsingEncoding(NSUTF8StringEncoding), response: nil, error: nil)
        
        waitForExpectationsWithTimeout(1) { error in
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
        
        let expectation = expectationWithDescription("NativeAdsRequest calls the delegate didReceiveResults method due to the fact that it has received a proper response back from the server.")
        delegate.didReceiveResultsExpectation = expectation
        delegate.didReceiveResultsResult = false
        
        let nativeAdsrequest = NativeAdsRequest(adPlacementToken: "test", delegate: delegate)
        
        nativeAdsrequest.receivedAds(testData, response: nil, error: nil)
        
        waitForExpectationsWithTimeout(1) { error in
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
    
}
