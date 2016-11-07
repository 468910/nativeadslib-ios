//
//  NativeAdTableViewDelegateTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import XCTest
import UIKit
@testable import PocketMediaNativeAds

open class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
    var didSelectRowAt: Bool! = false
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAtIndexPath = true
    }
}

class mockedNativeAdTableViewDataSource: NativeAdTableViewDataSource {
    var returngetNativeAdListing: Bool = false
    var getNativeAdListingCalled: Bool = false
    var adListing: NativeAdListing?

    override func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
            return adListing
        }
        return nil
    }
}

class mockedUIViewController: UIViewController {
}

class mockedNativeAd: NativeAd {
    var openAdUrlCalled: Bool = false

    override func openAdUrl(_ opener: NativeAdOpenerDelegate) {
        openAdUrlCalled = true
    }
}

class mockedNativeAdStream: NativeAdStream {
}

class NativeAdTableViewDelegateTest: XCTestCase {

    var tableViewDataSource: ExampleTableViewDataSource?

    var subject: NativeAdTableViewDelegate!
    var datasource: mockedNativeAdTableViewDataSource!
    var adStream: mockedNativeAdStream!
    var controller: mockedUIViewController!
    var delegate: UITableViewDelegate!

    var tableView: UITableView!

    override func setUp() {
        super.setUp()
    }

    // Our own setup. Due to the fact that we want to have a custom delegate class with each test.
    func setup2(_ delegate: UITableViewDelegate) {
        controller = mockedUIViewController(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        self.delegate = delegate

        // These 3 lines are directly from the example app
        tableViewDataSource = ExampleTableViewDataSource()
        // tableViewDataSource?.loadLocalJSON() we don't need this in our unit tests
        tableView.dataSource = tableViewDataSource

        tableView.delegate = self.delegate
        adStream = mockedNativeAdStream(controller: controller, view: tableView, adPlacementToken: "test")

        datasource = mockedNativeAdTableViewDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))

        do {
            let ad = try mockedNativeAd(adDictionary: testHelpers.getNativeAdData()!, adPlacementToken: "test")
            datasource.adListing = NativeAdListing(ad: ad, position: 0, numOfAdsBefore: 0)
        } catch {
            XCTFail("Could not create an instance of NativeAd")
        }

        subject = NativeAdTableViewDelegate(datasource: datasource, controller: controller, delegate: delegate)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testdidSelectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didSelectRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                didSelectRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        datasource.returngetNativeAdListing = false
        subject?.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didSelectRowAtIndexPath = false

        let ad = (datasource.adListing!.ad as! mockedNativeAd)

        ad.openAdUrlCalled = false

        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(ad.openAdUrlCalled, "It should've called our function")
        mockedDelegate.didSelectRowAtIndexPath = false
        ad.openAdUrlCalled = false
        datasource.returngetNativeAdListing = false

        // If adsteam is weak + optional
        //        subject.datasource.adStream = nil
        //        datasource.returngetNativeAdListing = true
        //        subject?.tableView(tableView, didSelectRowAt: NSIndexPath(row: 1, section: 0))
        //        XCTAssert(mockedDelegate.didSelectRowAtIndexPath == false, "It should NOT have called the orginal function, since our adStream is nil")
    }

    func testHeightForHeaderInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(123)
            var HeightForHeaderInSection: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                HeightForHeaderInSection = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, heightForHeaderInSection: 0)
        XCTAssert(mockedDelegate.HeightForHeaderInSection, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        mockedDelegate.HeightForHeaderInSection = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, heightForHeaderInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
    }

    func testHeightForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(123)
            var heightForRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                heightForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(mockedDelegate.heightForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        mockedDelegate.heightForRowAtIndexPath = false
        datasource.getNativeAdListingCalled = false

        // Is an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(result == NativeAdTableViewDelegate.heightForStandardAdUnit, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        datasource.returngetNativeAdListing = false
        datasource.getNativeAdListingCalled = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
    }

    func testViewForHeaderInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = UIView()
            @objc
            func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                Logger.debug("hi there")
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        let result = subject.tableView(tableView, viewForHeaderInSection: 0)
        XCTAssert(result == mockedDelegate.expected, "Implementation didn't pass the function through.")
    }

    func testAccessoryButtonTappedForRowWithIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var AccessoryButtonTappedForRowWithIndexPath: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
                AccessoryButtonTappedForRowWithIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        datasource.returngetNativeAdListing = false
        subject?.tableView(tableView, accessoryButtonTappedForRowWith: IndexPath(row: 0, section: 0))
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.AccessoryButtonTappedForRowWithIndexPath, "It should've called the orginal function")
        mockedDelegate.AccessoryButtonTappedForRowWithIndexPath = false
        datasource.getNativeAdListingCalled = false

        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, accessoryButtonTappedForRowWith: IndexPath(row: 0, section: 0))
        XCTAssert(!mockedDelegate.AccessoryButtonTappedForRowWithIndexPath, "It should've called the orginal function")
    }

    func testCanFocusRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var canFocusRowAt: Bool! = false
            var expected: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
                canFocusRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // Implemented, no ads
        datasource.returngetNativeAdListing = false
        var result = subject?.tableView(tableView, canFocusRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canFocusRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canFocusRowAtIndexPath function we should return the value its returning.")

        mockedDelegate.canFocusRowAtIndexPath = false
        datasource.getNativeAdListingCalled = false

        // We have ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, canFocusRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == true, "return value should be true since we have an ad.")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // Not implemented and no ads means true
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, canFocusRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == true, "Return true since we the delegate hasn't got this function implemented.")
    }

    func testDidDeselectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didDeselectRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
                didDeselectRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        // We don't have an ad
        subject?.tableView(tableView, didDeselectRowAt: IndexPath(row: 0, section: 0))
        datasource.returngetNativeAdListing = false
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didDeselectRowAtIndexPath, "It should've called the orginal function")
    }

    func testDidEndDisplayingCellxPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingCell: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
                didEndDisplayingCell = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        // We don't have an ad
        subject?.tableView(tableView, didEndDisplayingCell: uitableviewcell, forRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndDisplayingCell, "It should have called the orginal function")
        mockedDelegate.didEndDisplayingCell = false

        // We have ad
        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, didEndEditingRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didEndDisplayingCell == false, "It should NOT have called the orginal function")
    }

    func testDidEndDisplayingFooterView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingFooterView: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
                didEndDisplayingFooterView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        subject?.tableView(tableView, didEndDisplayingFooterView: uitableviewcell, forSection: 1)
        XCTAssert(mockedDelegate.didEndDisplayingFooterView, "It should've called the orginal function")
    }

    func testDidEndEditingRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndEditingRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
                didEndEditingRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        // We don't have an ad
        subject?.tableView(tableView, didEndEditingRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndEditingRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didEndEditingRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, didEndEditingRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didEndEditingRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidEndDisplayingHeaderView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingHeaderView: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
                didEndDisplayingHeaderView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        // We don't have an ad
        subject?.tableView(tableView, didEndDisplayingHeaderView: uitableviewcell, forSection: 1)
        XCTAssert(mockedDelegate.didEndDisplayingHeaderView, "It should've called the orginal function")
    }

    func testCanPerformAction() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var canPerformAction: Bool! = false
            var expected: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
                canPerformAction = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        var result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAt: IndexPath(row: 0, section: 0), withSender: nil)
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canPerformAction, "It should have called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canPerformAction function we should return the value its returning.")
        mockedDelegate.canPerformAction = false

        // We have ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAt: IndexPath(row: 0, section: 0), withSender: nil)
        XCTAssert(mockedDelegate.canPerformAction == false, "It should NOT have called the orginal function")
        XCTAssert(result == true, "If it is an ad return true")

        // We don't have an ad and its not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // Not implemented and no ads means true
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAt: IndexPath(row: 0, section: 0), withSender: nil)
        XCTAssert(result == true, "Default value is true. Not implemented")
    }

    func testDidHighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didHighlightRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
                didHighlightRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        subject?.tableView(tableView, didHighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didHighlightRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didHighlightRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, didHighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didHighlightRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidUnhighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUnhighlightRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
                didUnhighlightRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        subject?.tableView(tableView, didUnhighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didUnhighlightRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didUnhighlightRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        subject?.tableView(tableView, didUnhighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.didUnhighlightRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidUpdateFocusInContext() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUpdateFocusInContext: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
                didUpdateFocusInContext = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, didUpdateFocusInContext: UITableViewFocusUpdateContext(), withAnimationCoordinator: UIFocusAnimationCoordinator())
        XCTAssert(mockedDelegate.didUpdateFocusInContext, "It should've called the orginal function")
    }

    func testEditActionsForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var editActionsForRowAt: Bool! = false
            var expected: [UITableViewRowAction] = [UITableViewRowAction(), UITableViewRowAction()]
            @objc
            func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
                editActionsForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        var result = subject?.tableView(tableView, editActionsForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.editActionsForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the editActionsForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.editActionsForRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, editActionsForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.editActionsForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == nil, "When it is an ad. return nil")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // We don't have an ad and its not implemented
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, editActionsForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == nil, "Default value is nil. Not implemented")
    }

    func testEditingStyleForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var editingStyleForRowAt: Bool! = false
            var expected: UITableViewCellEditingStyle = UITableViewCellEditingStyle.insert
            @objc
            func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
                editingStyleForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        var result = subject?.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.editingStyleForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the editingStyleForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.editingStyleForRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.editingStyleForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == UITableViewCellEditingStyle.None, "When it is an ad. return nil")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // We don't have an ad and its not implemented
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == UITableViewCellEditingStyle.None, "Default value is nil. Not implemented")
    }

    func testEstimatedHeightForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(1337)
            var estimatedHeightForFooterInSection: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
                estimatedHeightForFooterInSection = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, estimatedHeightForFooterInSection: 0)
        XCTAssert(mockedDelegate.estimatedHeightForFooterInSection, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the estimatedHeightForFooterInSection function we should return the value its returning.")
        mockedDelegate.estimatedHeightForFooterInSection = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, estimatedHeightForFooterInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the estimatedHeightForFooterInSection function we should return the value its returning.")
    }

    func testEstimatedHeightForHeaderInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(1337)
            var estimatedHeightForHeaderInSection: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
                estimatedHeightForHeaderInSection = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, estimatedHeightForHeaderInSection: 0)
        XCTAssert(mockedDelegate.estimatedHeightForHeaderInSection, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the estimatedHeightForFooterInSection function we should return the value its returning.")
        mockedDelegate.estimatedHeightForHeaderInSection = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, estimatedHeightForHeaderInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the estimatedHeightForFooterInSection function we should return the value its returning.")
    }

    func testEstimatedHeightForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var estimatedHeightForRowAt: Bool! = false
            var expected: CGFloat = CGFloat(188)
            @objc
            func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
                estimatedHeightForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        var result = subject?.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.estimatedHeightForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the estimatedHeightForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.estimatedHeightForRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.estimatedHeightForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == UITableViewAutomaticDimension, "When it is an ad. return nil")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // We don't have an ad and its not implemented
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Default value is nil. Not implemented")
    }

    func testHeightForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(1337)
            var heightForFooterInSection: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
                heightForFooterInSection = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, heightForFooterInSection: 0)
        XCTAssert(mockedDelegate.heightForFooterInSection, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the heightForFooterInSection function we should return the value its returning.")
        mockedDelegate.heightForFooterInSection = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, heightForFooterInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForFooterInSection function we should return the value its returning.")
    }

    func testIndentationLevelForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var indentationLevelForRowAt: Bool! = false
            var expected: Int = 123 // This is magic ~ Harry Potter.
            @objc
            func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
                indentationLevelForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        // We don't have an ad
        var result = subject?.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.indentationLevelForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the indentationLevelForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.indentationLevelForRowAtIndexPath = false

        // We have an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.indentationLevelForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == -1, "When it is an ad. return nil")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        // We don't have an ad and its not implemented
        datasource.getNativeAdListingCalled = false
        result = subject?.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == -1, "Default value is nil. Not implemented")
    }

    func testPerformAction() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var performAction: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
                performAction = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, performAction: Selector(), forRowAt: IndexPath(row: 0, section: 0), withSender: nil)
        XCTAssert(mockedDelegate.performAction, "It should've called the orginal function")
    }

    func testShouldHighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldHighlightRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
                shouldHighlightRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldHighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.shouldHighlightRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldHighlightRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldHighlightRowAtIndexPath = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldHighlightRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldHighlightRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldIndentWhileEditingRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldIndentWhileEditingRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
                shouldIndentWhileEditingRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldIndentWhileEditingRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.shouldIndentWhileEditingRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldIndentWhileEditingRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldIndentWhileEditingRowAtIndexPath = false

        // Is an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, shouldIndentWhileEditingRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(result == true, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        datasource.returngetNativeAdListing = false
        datasource.getNativeAdListingCalled = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldIndentWhileEditingRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldIndentWhileEditingRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldShowMenuForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldShowMenuForRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
                shouldShowMenuForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldShowMenuForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(mockedDelegate.shouldShowMenuForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldShowMenuForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldShowMenuForRowAtIndexPath = false

        // Is an ad
        datasource.returngetNativeAdListing = true
        result = subject?.tableView(tableView, shouldShowMenuForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(result == true, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.getNativeAdListingCalled, "The function checked if it was an ad.")
        datasource.returngetNativeAdListing = false
        datasource.getNativeAdListingCalled = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldShowMenuForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldShowMenuForRowAtIndexPath function we should return the value its returning.")
    }

    func testWillSelectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = IndexPath(item: 123, section: 144)
            var willSelectRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
                willSelectRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, willSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(mockedDelegate.willSelectRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.willSelectRowAtIndexPath = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = IndexPath(item: 1, section: 0)
        result = subject?.tableView(tableView, willSelectRowAt: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldUpdateFocusInContext() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: Bool! = false
            var shouldUpdateFocusInContext: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
                shouldUpdateFocusInContext = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldUpdateFocusInContext: UITableViewFocusUpdateContext())
        XCTAssert(mockedDelegate.shouldUpdateFocusInContext, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldUpdateFocusInContext = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldUpdateFocusInContext: UITableViewFocusUpdateContext())
        XCTAssert(result == true, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
    }

    func testTargetIndexPathForMoveFromRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: IndexPath! = IndexPath(item: 10, section: 123)
            var shouldUpdateFocusInContext: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
                shouldUpdateFocusInContext = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, targetIndexPathForMoveFromRowAt: IndexPath(row: 1, section: 0), toProposedIndexPath: IndexPath(row: 123, inSection: 10))

        XCTAssert(mockedDelegate.shouldUpdateFocusInContext, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the targetIndexPathForMoveFromRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldUpdateFocusInContext = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = IndexPath(index: 1)
        result = subject?.tableView(tableView, targetIndexPathForMoveFromRowAt: IndexPath(row: 1, section: 0), toProposedIndexPath: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the targetIndexPathForMoveFromRowAtIndexPath function we should return the value its returning.")
    }

    func testTitleForDeleteConfirmationButtonForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: String! = "a test"
            var titleForDeleteConfirmationButtonForRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
                titleForDeleteConfirmationButtonForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: IndexPath(row: 1, section: 0))

        XCTAssert(mockedDelegate.titleForDeleteConfirmationButtonForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the titleForDeleteConfirmationButtonForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.titleForDeleteConfirmationButtonForRowAtIndexPath = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(result == nil, "Since the delegate has implemented the titleForDeleteConfirmationButtonForRowAtIndexPath function we should return the value its returning.")
    }

    func testViewForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUpdateFocusInContext: Bool! = false
            var expected: UIView! = UIView()
            @objc
            func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                didUpdateFocusInContext = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        let result = subject?.tableView(tableView, viewForFooterInSection: 123)
        XCTAssert(mockedDelegate.didUpdateFocusInContext, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the viewForFooterInSection function we should return the value its returning.")
    }

    func testWillBeginEditingRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willBeginEditingRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
                willBeginEditingRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, willBeginEditingRowAt: IndexPath(row: 123, inSection: 10))
        XCTAssert(mockedDelegate.willBeginEditingRowAtIndexPath, "It should've called the orginal function")
    }

    func testWillDeselectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: IndexPath! = IndexPath(item: 10, section: 123)
            var willDeselectRowAt: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willDeselectRowAt sourceIndexPath: IndexPath) -> IndexPath? {
                willDeselectRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, willDeselectRowAt: IndexPath(row: 1, section: 0))

        XCTAssert(mockedDelegate.willDeselectRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the willDeselectRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.willDeselectRowAtIndexPath = false

        // Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = IndexPath(index: 1)
        result = subject?.tableView(tableView, willDeselectRowAt: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the willDeselectRowAtIndexPath function we should return the value its returning.")
    }

    func testWillDisplayCell() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willDisplayCell: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
                willDisplayCell = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        subject?.tableView(tableView, willDisplayCell: uitableviewcell, forRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(mockedDelegate.willDisplayCell, "It should've called the orginal function")
    }

    func testWillDisplayFooterView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willDisplayFooterView: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
                willDisplayFooterView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, willDisplayFooterView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)), forSection: 123)
        XCTAssert(mockedDelegate.willDisplayFooterView, "It should've called the orginal function")
    }

    func testWillDisplayHeaderView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willDisplayHeaderView: Bool! = false
            @objc
            func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
                willDisplayHeaderView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, willDisplayHeaderView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)), forSection: 123)
        XCTAssert(mockedDelegate.willDisplayHeaderView, "It should've called the orginal function")
    }
}
