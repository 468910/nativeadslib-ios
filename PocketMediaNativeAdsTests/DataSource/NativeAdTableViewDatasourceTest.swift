//
//  NativeAdTableViewDatasource.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 20/09/16.
//
//

import XCTest
import UIKit
@testable import PocketMediaNativeAds

class BaseMockedNativeAdDataSource: NativeAdTableViewDataSource {
    var returngetNativeAdListing: Bool = false
    var getNativeAdListingCalled: Bool = false
    var isGetAdCellForTableViewCalled: Bool = false
    var adListing: NativeAdListing?

    override func getNativeAdListing(indexPath: NSIndexPath) -> NativeAdListing? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
            return adListing
        }
        return nil
    }

    override func getAdCell(nativeAd: NativeAd) -> AbstractAdUnitTableViewCell {
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

class baseMockedDelegate: NSObject, UITableViewDelegate {
}

public class NativeAdTableViewDatasourceTest: XCTestCase {

    var subject: BaseMockedNativeAdDataSource!
    var originalDataSource: UITableViewDataSource!
    var tableView: UITableView!
    var controller: UIViewController!

    public override func setUp() {
        super.setUp()
    }

    func setUpDataSource(mockedDatasource: UITableViewDataSource) {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
        controller.view = tableView

        tableView.delegate = baseMockedDelegate()

        originalDataSource = mockedDatasource
        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }

        tableView.dataSource = originalDataSource
        subject = BaseMockedNativeAdDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))
    }

    func testcellForRowAtIndexPath() {
        class mockedDatasource: ExampleTableViewDataSource {
            public var calledCellForRowAtIndexPath: Bool = false
            @objc override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                calledCellForRowAtIndexPath = true
                return UITableViewCell()
            }
        }

        setUpDataSource(mockedDatasource())
        let view = UITableView()

        // Test If Original IndexPathForRowAtIndexPath gets called
        subject.returngetNativeAdListing = false
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let result = (originalDataSource as! mockedDatasource).calledCellForRowAtIndexPath
        XCTAssert(result == true, "cellForRowAtIndexPath has been called in the original DataSource")

        // Test if NativeAdCell gets returned
        subject.returngetNativeAdListing = true
        subject.setup()
        subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        XCTAssert(subject.isGetAdCellForTableViewCalled == true, "isGetAdCellForTableViewHasBeenCalled")
    }

    func testTitleForHeaderInSection() {
        class mockedDataSource: ExampleTableViewDataSource {
            public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
            public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
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
            public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                commitEditingStyleHasBeenCalled = true
            }
        }
        /*
         setUpDataSource(mockedDataSource())
         subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 1))
         XCTAssert((originalDataSource as! mockedDataSource!).commitEditingStyleHasBeenCalled == true, "Called original commitEditingStyle")
         */

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:commitEditingStyle:forRowAtIndexPath:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
    }

    func testmoveRowAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var moveRowAtIndexPathHasBeenCalled = false
            public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
                moveRowAtIndexPathHasBeenCalled = true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, moveRowAtIndexPath: NSIndexPath(), toIndexPath: NSIndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).moveRowAtIndexPathHasBeenCalled == true, "MoveRowAtIndexPathHasBeenCalled")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:moveRowAtIndexPath:toIndexPath:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
    }

    func testsectionForSectionIndexTitle() {

        class mockedDataSource: ExampleTableViewDataSource {
            var sectionForSectionIndexTitleHasBeenCalled = false
            public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
                sectionForSectionIndexTitleHasBeenCalled = true
                return 0
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, sectionForSectionIndexTitle: "yay", atIndex: 0)
        XCTAssert((originalDataSource as! mockedDataSource).sectionForSectionIndexTitleHasBeenCalled == true, "Section for Section Index title has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.respondsToSelector(#selector(UITableViewDataSource.sectionIndexTitlesForTableView(_:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }

        var result = subject.tableView(tableView, sectionForSectionIndexTitle: "yay", atIndex: 1)
        XCTAssert(result == 0, "Section for section index title has been called")
    }

    func testcanEditRowAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var canEditRowAtIndexPathHasBeenCalled = false
            public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                canEditRowAtIndexPathHasBeenCalled = true
                return true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, canEditRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert((originalDataSource as! mockedDataSource).canEditRowAtIndexPathHasBeenCalled == true, "CanEditRowAtIndexPath has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:canEditRowAtIndexPath:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
        var result = subject.tableView(tableView, canEditRowAtIndexPath: NSIndexPath())
        XCTAssert(result == true, "Can Edit Row At IndexPath returns default value which is TRUE")
    }

    func testcanMoveAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
            var canMoveRowAtIndexPathHasBeenCalled = false
            public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                canMoveRowAtIndexPathHasBeenCalled = true
                return true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, canMoveRowAtIndexPath: NSIndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).canMoveRowAtIndexPathHasBeenCalled == true, "canMoveRowAtIndexPathHasBeenCalled has been called!")

        setUpDataSource(NonImplementedDatasource())
        if originalDataSource.respondsToSelector(#selector(UITableViewDataSource.tableView(_:canMoveRowAtIndexPath:))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }

        var result = subject.tableView(tableView, canMoveRowAtIndexPath: NSIndexPath())
        XCTAssert(result == true, "Can Move Row At Index Path returns default value which is True")
    }

    func testcommitEditingStyle() {
        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCommited = false
            public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                commitEditingStyleHasBeenCommited = true
            }
        }

        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: NSIndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).commitEditingStyleHasBeenCommited == true, "CommitEditingStyle has been called!")
    }

    func testGetAdCellForTableView() {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
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
            override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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

        var result = subject.getOriginalPositionForElement(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssert(result.row == 1, "Because there is no ad listing on this row. We'll get the same row back we sent")

        result = subject.getOriginalPositionForElement(NSIndexPath(forRow: 3, inSection: 0))
        XCTAssert(result.row == 3, "When we ask for 3. It is an ad, so we don't normalize")

        result = subject.getOriginalPositionForElement(NSIndexPath(forRow: 4, inSection: 0))
        XCTAssert(result.row == 3, "When we ask for 4, we should get 3. Because there is an ad at 3")
    }
}
