//
//  ReferenceArrayTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class PocketMediaNativeAdsBundleTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoadBundle() {
        XCTAssert(PocketMediaNativeAdsBundle.loadBundle() == NSBundle(forClass: NativeAd.self))
    }
}
