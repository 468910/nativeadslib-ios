//
//  NativeAdTableViewDatasource.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 20/09/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import XCTest
import UIKit
@testable import PocketMediaNativeAds

class BaseMockedNativeAdDataSource: NativeAdTableViewDataSource {
    var returngetNativeAdListing: Bool = false
    var getNativeAdListingCalled: Bool = false
    var isGetAdCellForTableViewCalled: Bool = false
    var adListing: NativeAdListing?

    override func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
            return adListing
        }
        return nil
    }

    override func getAdCell(_ nativeAd: NativeAd) -> AbstractAdUnitTableViewCell {
        isGetAdCellForTableViewCalled = true
        return StandardAdUnitTableViewCell() as AbstractAdUnitTableViewCell
    }

    func setup() {
        let data = testHelpers.getNativeAdData()!
        let ad = try? NativeAd(adDictionary: data, adPlacementToken: "test")

        self.adListing = NativeAdListing(ad: ad!, position: 0, numOfAdsBefore: 0)
    }
}

class NonImplementedDatasource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

class baseMockedDelegate: NSObject, UITableViewDelegate {
}

open class NativeAdTableViewDatasourceTest: XCTestCase {

    var subject: BaseMockedNativeAdDataSource!
    var originalDataSource: UITableViewDataSource!
    var tableView: UITableView!
    var controller: UIViewController!

    open override func setUp() {
        super.setUp()
    }

    func setUpDataSource(_ mockedDatasource: UITableViewDataSource, margin: Int = 2) {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        controller.view = tableView

        tableView.delegate = baseMockedDelegate()

        originalDataSource = mockedDatasource
        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }

        tableView.dataSource = originalDataSource
        subject = BaseMockedNativeAdDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: margin))
    }

    func testcellForRowAtIndexPath() {
        class mockedDatasource: ExampleTableViewDataSource {
            open var calledCellForRowAt: Bool = false
            @objc override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                calledCellForRowAt = true
                return UITableViewCell()
            }
        }

        setUpDataSource(mockedDatasource())
        let view = UITableView()

        // Test If Original IndexPathForRowAtIndexPath gets called
        subject.returngetNativeAdListing = false
        let indexPath = IndexPath(item: 0, section: 0)
        subject.tableView(tableView, cellForRowAt: indexPath)
        let result = (originalDataSource as! mockedDatasource).calledCellForRowAt
        XCTAssert(result == true, "cellForRowAtIndexPath has been called in the original DataSource")

        // Test if NativeAdCell gets returned
        subject.returngetNativeAdListing = true
        subject.setup()
        subject.tableView(tableView, cellForRowAt: indexPath)
        XCTAssert(subject.isGetAdCellForTableViewCalled == true, "isGetAdCellForTableViewHasBeenCalled")
    }

    func testTitleForHeaderInSection() {
        class mockedDataSource: ExampleTableViewDataSource {
            open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }

        setUpDataSource(mockedDataSource())

        var result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")

        setUpDataSource(NonImplementedDatasource())

        result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")
    }

    func testTitleForFooterInSection() {
        class mockedDataSource: ExampleTableViewDataSource {
            open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }

        setUpDataSource(mockedDataSource())

        var result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")

        setUpDataSource(NonImplementedDatasource())

        result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")
    }

    func testCommitEditingStyle() {
        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCalled: Bool = false
            open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
                commitEditingStyleHasBeenCalled = true
            }
        }
        /*
         setUpDataSource(mockedDataSource())
         subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAt: NSIndexPath(row: 1, section: 1))
         XCTAssert((originalDataSource as! mockedDataSource!).commitEditingStyleHasBeenCalled == true, "Called original commitEditingStyle")
         */

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
    }

    func testmoveRowAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var moveRowAtIndexPathHasBeenCalled = false
            open func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
                moveRowAtIndexPathHasBeenCalled = true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, moveRowAt: IndexPath(), to: IndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).moveRowAtIndexPathHasBeenCalled == true, "MoveRowAtIndexPathHasBeenCalled")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
    }

    func testsectionForSectionIndexTitle() {

        class mockedDataSource: ExampleTableViewDataSource {
            var sectionForSectionIndexTitleHasBeenCalled = false
            open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
                sectionForSectionIndexTitleHasBeenCalled = true
                return 0
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, sectionForSectionIndexTitle: "yay", at: 0)
        XCTAssert((originalDataSource as! mockedDataSource).sectionForSectionIndexTitleHasBeenCalled == true, "Section for Section Index title has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.responds(to: #selector(UITableViewDataSource.sectionIndexTitles(for:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }

        var result = subject.tableView(tableView, sectionForSectionIndexTitle: "yay", at: 1)
        XCTAssert(result == 0, "Section for section index title has been called")
    }

    func testcanEditRowAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var canEditRowAtIndexPathHasBeenCalled = false
            open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
                canEditRowAtIndexPathHasBeenCalled = true
                return true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, canEditRowAt: IndexPath(row: 1, section: 0))
        XCTAssert((originalDataSource as! mockedDataSource).canEditRowAtIndexPathHasBeenCalled == true, "CanEditRowAtIndexPath has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
        var result = subject.tableView(tableView, canEditRowAt: IndexPath())
        XCTAssert(result == true, "Can Edit Row At IndexPath returns default value which is TRUE")
    }

    func testcanMoveAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var canMoveRowAtIndexPathHasBeenCalled = false
            open func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
                canMoveRowAtIndexPathHasBeenCalled = true
                return true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, canMoveRowAt: IndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).canMoveRowAtIndexPathHasBeenCalled == true, "canMoveRowAtIndexPathHasBeenCalled has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }

        var result = subject.tableView(tableView, canMoveRowAt: IndexPath())
        XCTAssert(result == true, "Can Move Row At Index Path returns default value which is True")
    }

    func testcommitEditingStyle() {
        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCommited = false
            open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
                commitEditingStyleHasBeenCommited = true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, commit: UITableViewCellEditingStyle.delete, forRowAt: IndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).commitEditingStyleHasBeenCommited == true, "CommitEditingStyle has been called!")
    }

    func testGetAdCellForTableView() {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        controller.view = tableView

        tableView.delegate = baseMockedDelegate()

        originalDataSource = NonImplementedDatasource()

        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }
        tableView.dataSource = originalDataSource

        var localsubject = BaseMockedNativeAdDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))

        var data = testHelpers.getNativeAdData()!
        var ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")

        var result = localsubject.getAdCell(ad)
        XCTAssert(result is StandardAdUnitTableViewCell, "Succesfully return StandardAdUnitTableViewCell")
    }

    func testGetOriginalPositionForElement() {
        class mockedDatasource: ExampleTableViewDataSource {
            @objc
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                return UITableViewCell()
            }
        }

        setUpDataSource(mockedDatasource())

        let ad = testHelpers.getNativeAd()
        subject.adListingsPerSection = [
            0: [
                3: NativeAdListing(ad: ad, position: 3, numOfAdsBefore: 1),
            ],
        ]

        var result = subject.getOriginalPositionForElement(IndexPath(row: 1, section: 0))
        XCTAssert(result.row == 1, "Because there is no ad listing on this row. We'll get the same row back we sent")

        result = subject.getOriginalPositionForElement(IndexPath(row: 3, section: 0))
        XCTAssert(result.row == 3, "When we ask for 3. It is an ad, so we don't normalize")

        result = subject.getOriginalPositionForElement(IndexPath(row: 4, section: 0))
        XCTAssert(result.row == 3, "When we ask for 4, we should get 3. Because there is an ad at 3")
    }

    fileprivate func setupSetAdPositions(_ rows: Int = 2, margin: Int = 1, sections: Int = 2) {
        class mockedDatasource: ExampleTableViewDataSource {
            @objc
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                return UITableViewCell()
            }

            var rows: Int = 1
            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return rows
            }

            var sections: Int = 2
            override func numberOfSections(in tableView: UITableView) -> Int {
                return sections
            }
        }
        let dataSource = mockedDatasource()

        let ads = testHelpers.getNativeAds()
        XCTAssert(ads.count == 2, "For this test we need 2 ads")

        dataSource.rows = rows
        dataSource.sections = sections
        setUpDataSource(dataSource, margin: margin)

        // Call subject
        subject.setAdPositions(ads)
    }

    func testSetAdPositions() {

        // 2 rows. 1 ad margin. 2 ads. Should fit.
        setupSetAdPositions(2, margin: 1)
        var result = subject.adListingsPerSection

        // Expected:
        /** Section 0:
         0 = item.
         1 = ad.
         2 = item.
         3 = ad.
         */
        XCTAssert(result.count == 1, "One section. Because it should fit.")
        XCTAssert(result[0]?.count == 2, "We have two ads. And two ads should fit with 2 rows and 1 margin.")
        XCTAssertNotNil(result[0]?[1], "First ad should be on position 1")
        XCTAssert(result[0]?[1]!.position == 1, "Position should be the same as the index")

        // If we only have 1 row. Then we should use the second section
        // Expected:
        /** Section 0:
         0 = item.
         1 = ad.
         Section 1:
         0 = item
         1 = ad
         */
        setupSetAdPositions(1, margin: 1)
        result = subject.adListingsPerSection

        XCTAssert(result.count == 2, "Because we have two ads. And a ad margin of 1. We should be using the second section!")
        XCTAssert(result[0]?.count == 1)
        XCTAssert(result[1]?.count == 1)

        XCTAssertNotNil(result[0]?[1], "First ad should be on position 1")
        XCTAssert(result[0]?[1]!.position == 1, "Position should be the same as the index")

        XCTAssertNotNil(result[1]?[1], "Second ad should be on position 1")
        XCTAssert(result[1]?[1]!.position == 1, "Position should be the same as the index")

        // If we have a higher ad margin. It won't fit.
        // Expected:
        /** Section 0:
         0 = item.
         1 = item.
         */
        setupSetAdPositions(2, margin: 3, sections: 1)
        result = subject.adListingsPerSection
        XCTAssert(result.count == 0, "Not enough room for ads! Because the margin is 3 and there is just 1 section of this.")

        // If we only have 10 row. We should not be using another section
        // Expected:
        /** Section 0:
         0 = item.
         1 = item.
         2 = item.
         3 = ad.
         4 = item.
         5 = item.
         6 = item.
         7 = ad.
         8 = item.
         9 = item.
         10 = item.
         */
        setupSetAdPositions(10, margin: 3)
        result = subject.adListingsPerSection

        XCTAssert(result.count == 1, "Enough space. No need for more than 1 section")
        XCTAssert(result[0]?.count == 2, "Our two ads should fit with a ad margin of 3")

        XCTAssertNotNil(result[0]?[3], "First ad should be on position 3")
        XCTAssert(result[0]?[3]!.position == 3, "Position should be the same as the index")

        XCTAssertNotNil(result[0]?[7], "Second ad should be on position 7")
        XCTAssert(result[0]?[7]!.position == 7, "Position should be the same as the index")
    }
}
