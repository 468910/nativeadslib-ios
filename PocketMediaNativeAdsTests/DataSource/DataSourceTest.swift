//
//  DataSourceTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 20/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class mockDataSource: DataSource {
    var getTruePositionInDataSourceCalled: Bool! = false
    var returnGetTruePositionInDataSource: Int = 0
    override func getTruePositionInDataSource(indexPath: NSIndexPath) -> Int {
        getTruePositionInDataSourceCalled = true
        return returnGetTruePositionInDataSource
    }
}

class DataSourceTest: XCTestCase {

    var subject: mockDataSource!

    override func setUp() {
        super.setUp()

        subject = mockDataSource()
        subject.ads = [Int: NativeAd]()

        var i = 0
        for adDict in testHelpers.getNativeAdsData()! {
            do {
                let ad = try NativeAd(adDictionary: adDict, adPlacementToken: "test")
                subject.ads[i] = ad
                i = i + 1
            } catch {
                XCTFail("Could not make ad")
            }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        var result = subject.isAdAtposition(NSIndexPath(index: 123))
        XCTAssert(subject.getTruePositionInDataSourceCalled, "isAdAtPosition should call getTruePositionInDataSourceCalled")
        XCTAssert(result != nil, "Returns a valid ad")
        
        //Test when the return value is not a valid index of our ads.
        subject.returnGetTruePositionInDataSource = 9999
        result = subject.isAdAtposition(NSIndexPath(index: 123))
        XCTAssert(result == nil, "Returns nil")
        
    }

}
