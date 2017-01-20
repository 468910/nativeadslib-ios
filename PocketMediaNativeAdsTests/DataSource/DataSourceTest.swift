//
//  DataSourceTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 04/11/2016.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import XCTest
@testable import PocketMediaNativeAds

open class DataSourceTest: XCTestCase {

    var subject: DataSource!

    open override func setUp() {
        subject = DataSource(type: AdUnit.UIType.TableView, customXib: nil, adPosition: MarginAdPosition())

        let ad = testHelpers.getNativeAd()

        subject!.adListingsPerSection = [
            0: [
                3: NativeAdListing(ad: ad, position: 3, numOfAdsBefore: 1),
                6: NativeAdListing(ad: ad, position: 6, numOfAdsBefore: 2),
            ],
            1: [
                4: NativeAdListing(ad: ad, position: 4, numOfAdsBefore: 1),
                8: NativeAdListing(ad: ad, position: 8, numOfAdsBefore: 2),
                10: NativeAdListing(ad: ad, position: 10, numOfAdsBefore: 3),
            ],
        ]
        super.setUp()
    }

    func testGetNativeAdListingHigherThan() {
        var result = subject.getNativeAdListingHigherThan(IndexPath(row: 1, section: 0))
        XCTAssertNil(result, "Before any ads. We shouldn't get any listings back.")

        result = subject.getNativeAdListingHigherThan(IndexPath(row: 3, section: 0))
        XCTAssertNil(result, "Even though we are asking for number 3. Which has an ad listing. A ad is displayed. So it should be nil")

        result = subject.getNativeAdListingHigherThan(IndexPath(row: 4, section: 0))
        XCTAssertNotNil(result, "Before row 4. On row 3 we had an adlisting. So we should find that one")
        XCTAssert(result!.position == 3, "We should get 3 back. Not 6. because we are at 4, at 3 is the closest.")
    }

    // With sections and 3 ad listings.
    func testSectionsGetNativeAdListingHigherThan() {
        var result = subject.getNativeAdListingHigherThan(IndexPath(row: 9, section: 1))
        XCTAssertNotNil(result, "Before row 4. On row 3 we had an adlisting. So we should find that one")
        XCTAssert(result!.position == 8, "We should get 8 back. Not 10 or 4. because we are at 9, at 8 is the closest.")

        result = subject.getNativeAdListingHigherThan(IndexPath(row: 300, section: 1))
        XCTAssert(result!.position == 10, "We should get 8 back. Not 10 or 4. because we are at 300, at 10 is the closest.")
    }

    func testGetNativeAdListing() {
        var result = subject.getNativeAdListing(IndexPath(row: 3, section: 0))
        XCTAssertNotNil(result, "Because row 3 in section 0 exists")
        result = subject.getNativeAdListing(IndexPath(row: 7, section: 0))
        XCTAssertNil(result, "Because row 8 in section 0 does NOT exists")
    }

    func testInitRegisterNib() {
        //        class mockedUITableView: UITableView {
        //            var registerNibCalled: Bool = false
        //            override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        //                registerNibCalled = true
        //            }
        //        }
        //
        //        let tableView = mockedUITableView()
        //        let tableViewDataSource = ExampleTableViewDataSource()
        //        tableViewDataSource.loadLocalJSON()
        //        tableView.dataSource = tableViewDataSource
        //
        //        subject = NativeAdStream(controller: controller, view: tableView, adPlacementToken: "test123", customXib: UINib(), requester: requester)
        //        XCTAssert(tableView.registerNibCalled, "registerNib called")
    }
}
