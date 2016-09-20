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
    public func getTruePositionInDataSource(indexPath: NSIndexPath) -> Int {

    }
}

class DataSourceTest: XCTestCase {

    var subject: mockDataSource!

    override func setUp() {
        super.setUp()

        subject = mockDataSource()
        subject.ads = [Int: NativeAd]()
        subject.ads = [NativeAd]()

        for adDict in testHelpers.getNativeAdsData()! {
            do {
                let ad = try NativeAd(adDictionary: adDict, adPlacementToken: "test")
                subject.ads.append(ad)
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
        subject.isAdAtposition(NSIndexPath(index: 123))
    }

}
