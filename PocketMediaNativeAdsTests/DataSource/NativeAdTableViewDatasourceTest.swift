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

class baseMockedNativeAdDataSource: NativeAdTableViewDataSource {
    var returngetNativeAdListing: Bool = false
    var getNativeAdListingCalled: Bool = false
    var isGetAdCellForTableViewCalled: Bool = false
    var ad: NativeAd?
    

    override func getNativeAdListing(_ indexPath: IndexPath) -> NativeAd? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
            return ad
        }
        
        return nil
    }

    override func getAdCell(_ nativeAd: NativeAd) -> NativeAdCell {
        isGetAdCellForTableViewCalled = true
        return NativeAdCell()
    }

    func setupAd() {
        let data = testHelpers.getNativeAdData()!
        self.ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")

    }
    
}

class nonImplementedDatasource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

class baseMockedDelegate: NSObject, UITableViewDelegate {

}

public class NativeAdTableViewDatasourceTest: XCTestCase {

    var subject: baseMockedNativeAdDataSource!
    var originalDataSource: UITableViewDataSource!
    public var tableView: UITableView!
    var controller: UIViewController!

    override public func setUp() {
        super.setUp()
    }

    func setUpDataSource(_ mockedDatasource: UITableViewDataSource) {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        controller.view = tableView

        tableView.delegate = baseMockedDelegate()

        originalDataSource = mockedDatasource
        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }

        tableView.dataSource = originalDataSource
        subject = baseMockedNativeAdDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))

    }

    func testcellForRowAtIndexPath() {

        class mockedDatasource: ExampleTableViewDataSource {
            public var calledCellForRowAtIndexPath: Bool = false
            @objc override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                calledCellForRowAtIndexPath = true
                return UITableViewCell()
            }
        }

        setUpDataSource(mockedDatasource())
        let view = UITableView()

        // Test If Original IndexPathForRowAtIndexPath gets called
        subject.returngetNativeAdListing = false
        let indexPath = IndexPath(item: 0, section: 0)
        subject.tableView(tableView, cellForRowAt: indexPath)
        let result = (originalDataSource as! mockedDatasource).calledCellForRowAtIndexPath
        XCTAssert(result == true, "cellForRowAtIndexPath has been called in the original DataSource")

        // Test if NativeAdCell gets returned
        subject.returngetNativeAdListing = true
        subject.setupAd()
        subject.tableView(tableView, cellForRowAt: indexPath)
        XCTAssert(subject.isGetAdCellForTableViewCalled == true, "isGetAdCellForTableViewHasBeenCalled")

    }

    func testTitleForHeaderInSection() {

        class mockedDataSource: ExampleTableViewDataSource {
            public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }

        setUpDataSource(mockedDataSource())

        var result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")

        setUpDataSource(nonImplementedDatasource())

        result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")

    }

    func testTitleForFooterInSection() {

        class mockedDataSource: ExampleTableViewDataSource {
            public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }

        setUpDataSource(mockedDataSource())

        var result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")

        setUpDataSource(nonImplementedDatasource())

        result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")

    }

    func testCommitEditingStyle() {

        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCalled: Bool = false
            public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
                commitEditingStyleHasBeenCalled = true
            }
        }
        
//        setUpDataSource(mockedDataSource())
//        subject.tableView(tableView, commit: UITableViewCellEditingStyle.Insert, forRowAt: NSIndexPath(forItem: 1, inSection: 1))
//        XCTAssert((originalDataSource as! mockedDataSource!).commitEditingStyleHasBeenCalled == true, "Called original commitEditingStyle")
//
//        setUpDataSource(nonImplementedDatasource())
//        if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:commit:editingStyle:)))) {
//            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
//        }
        
    }

//    func testmoveRowAtIndexPath() {
//
//        class mockedDataSource: ExampleTableViewDataSource {
//            var moveRowAtIndexPathHasBeenCalled = false
//            
//            //tableView(UITableView, moveRowAt: IndexPath, to: IndexPath)
//
//            func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//                moveRowAtIndexPathHasBeenCalled = true
//            }
//        }
//
//        setUpDataSource(mockedDataSource())
//        //tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath
//        subject.tableView(tableView, moveRowAt: IndexPath(item: 0, section: 0), to: IndexPath(item: 1, section: 0))
//        XCTAssert((originalDataSource as! mockedDataSource).moveRowAtIndexPathHasBeenCalled == true, "MoveRowAtIndexPathHasBeenCalled")
//
//        setUpDataSource(nonImplementedDatasource())
//        if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))) {
//            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
//        }
//    }
//
//    func testsectionForSectionIndexTitle() {
//
//        class mockedDataSource: ExampleTableViewDataSource {
//            var sectionForSectionIndexTitleHasBeenCalled = false
//            public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
//                sectionForSectionIndexTitleHasBeenCalled = true
//                return 0
//            }
//        }
//
//        setUpDataSource(mockedDataSource())
//        subject.tableView(tableView, sectionForSectionIndexTitle: "yay", at: 0)
//        XCTAssert((originalDataSource as! mockedDataSource).sectionForSectionIndexTitleHasBeenCalled == true, "Section for Section Index title has been called!")
//
//        setUpDataSource(nonImplementedDatasource())
//        if (originalDataSource.responds(to: #selector(UITableViewDataSource.sectionIndexTitles(`for`:)))) {
//            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
//        }
//
//        var result = subject.tableView(tableView, sectionForSectionIndexTitle: "yay", at: 1)
//        XCTAssert(result == 0, "Section for section index title has been called")
//    }

//    func testcanEditRowAtIndexPath() {
//
//        class mockedDataSource: ExampleTableViewDataSource {
//            var canEditRowAtIndexPathHasBeenCalled = false
//            public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//                canEditRowAtIndexPathHasBeenCalled = true
//                return true
//            }
//        }
//        
//        setUpDataSource(mockedDataSource())
//        
//        XCTAssert((originalDataSource as! mockedDataSource).canEditRowAtIndexPathHasBeenCalled == true, "CanEditRowAtIndexPath has been called!")
//        
//        subject.tableView(tableView, canEditRowAt: IndexPath(forItem: 1, inSection: 0))
//
//        setUpDataSource(nonImplementedDatasource())
//        if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)))) {
//            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
//        }
//        var result = subject.tableView(tableView, canEditRowAt: IndexPath(forItem: 1, inSection: 0))
//        XCTAssert(result == true, "Can Edit Row At IndexPath returns default value which is TRUE")
//    }

//    func testcanMoveAtIndexPath() {
//
//        class mockedDataSource: ExampleTableViewDataSource {
//            var canMoveRowAtIndexPathHasBeenCalled = false
//            public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//                canMoveRowAtIndexPathHasBeenCalled = true
//                return true
//            }
//        }
//
//        setUpDataSource(mockedDataSource())
//        subject.tableView(tableView, canMoveRowAt: IndexPath())
//        XCTAssert((originalDataSource as! mockedDataSource).canMoveRowAtIndexPathHasBeenCalled == true, "canMoveRowAtIndexPathHasBeenCalled has been called!")
//
//        setUpDataSource(nonImplementedDatasource())
//        if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)))) {
//            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
//        }
//
//        var result = subject.tableView(tableView, canMoveRowAt: IndexPath())
//        XCTAssert(result == true, "Can Move Row At Index Path returns default value which is True")
//
//
//    }


//    func testcommitEditingStyle() {
//
//        class mockedDataSource: ExampleTableViewDataSource {
//            var commitEditingStyleHasBeenCommited = false
//            public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//                commitEditingStyleHasBeenCommited = true
//            }
//            
//        }
//        
//        setUpDataSource(mockedDataSource())
//        subject.tableView(tableView, commit: UITableViewCellEditingStyle.delete, forRowAt: IndexPath())
//        XCTAssert((originalDataSource as! mockedDataSource).commitEditingStyleHasBeenCommited == true, "CommitEditingStyle has been called!")
//
//
//    }

    func testGetAdCellForTableView() {

        class xMocked: NativeAdTableViewDataSource {
            var returngetNativeAdListing: Bool = false
            var getNativeAdListingCalled: Bool = false
            var isGetAdCellForTableViewCalled: Bool = false
            var ad: NativeAd?

            override func getNativeAdListing(_ indexPath: IndexPath) -> NativeAd? {
                getNativeAdListingCalled = true
                if returngetNativeAdListing {
                    return ad
                }
                return nil
            }

            func setupAd() {
                let data = testHelpers.getNativeAdData()!
                self.ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")

            }
        }

        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        controller.view = tableView

        tableView.delegate = baseMockedDelegate()

        originalDataSource = nonImplementedDatasource()

        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }
        tableView.dataSource = originalDataSource

        let localsubject = xMocked(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))

        let data = testHelpers.getNativeAdData()!
        let ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")

        let result = localsubject.getAdCell(ad)
        XCTAssert(result is NativeAdCell, "Succesfully return NativeAdCell")

    }


}
