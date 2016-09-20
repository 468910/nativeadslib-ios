//
//  NativeAdTableViewDelegateTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import XCTest
import UIKit

public class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
    var didSelectRowAtIndexPath: Bool! = false
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectRowAtIndexPath = true
    }
}

class mockedNativeAdTableViewDataSource: NativeAdTableViewDataSource {
    var returnIsAdAtposition: Bool = false
    var isAdAtpositionCalled: Bool = false
    var ad: mockedNativeAd?

    override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        isAdAtpositionCalled = true
        if returnIsAdAtposition {
            return ad
        }
        return nil
    }
}

class mockedUIViewController: UIViewController {

}

class mockedNativeAd: NativeAd {
    var openAdUrlCalled: Bool = false

    override func openAdUrl(opener: NativeAdOpenerProtocol) {
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

    //Our own setup. Due to the fact that we want to have a custom delegate class with each test.
    func setup2(delegate: UITableViewDelegate) {
        controller = mockedUIViewController(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
        self.delegate = delegate

        //These 3 lines are directly from the example app
        tableViewDataSource = ExampleTableViewDataSource()
        //tableViewDataSource?.loadLocalJSON() we don't need this in our unit tests
        tableView.dataSource = tableViewDataSource

        tableView.delegate = self.delegate
        adStream = mockedNativeAdStream(controller: controller, view: tableView, adPlacementToken: "test")

        datasource = mockedNativeAdTableViewDataSource(controller: controller, tableView: tableView)

        do {
            datasource.ad = try mockedNativeAd(adDictionary: testHelpers.getNativeAdData()!, adPlacementToken: "test")
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
            var didSelectRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                didSelectRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        datasource.returnIsAdAtposition = false
        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didSelectRowAtIndexPath = false
        datasource.ad!.openAdUrlCalled = false

        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(datasource.ad!.openAdUrlCalled, "It should've called our function")
        mockedDelegate.didSelectRowAtIndexPath = false
        datasource.ad!.openAdUrlCalled = false
        datasource.returnIsAdAtposition = false

        //If adsteam is weak + optional
//        subject.datasource.adStream = nil
//        datasource.returnIsAdAtposition = true
//        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
//        XCTAssert(mockedDelegate.didSelectRowAtIndexPath == false, "It should NOT have called the orginal function, since our adStream is nil")
    }

    func testHeightForHeaderInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(123)
            var HeightForHeaderInSection: Bool! = false
            @objc
            func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, heightForHeaderInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
    }

    func testHeightForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(123)
            var heightForRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                heightForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.heightForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        mockedDelegate.heightForRowAtIndexPath = false
        datasource.isAdAtpositionCalled = false

        //Is an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == NativeAdTableViewDelegate.heightForStandardAdUnit, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        datasource.returnIsAdAtposition = false
        datasource.isAdAtpositionCalled = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")

    }

    func testViewForHeaderInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = UIView()
            @objc
            func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
                AccessoryButtonTappedForRowWithIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        datasource.returnIsAdAtposition = false
        subject?.tableView(tableView, accessoryButtonTappedForRowWithIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.AccessoryButtonTappedForRowWithIndexPath, "It should've called the orginal function")
        mockedDelegate.AccessoryButtonTappedForRowWithIndexPath = false
        datasource.isAdAtpositionCalled = false

        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, accessoryButtonTappedForRowWithIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(!mockedDelegate.AccessoryButtonTappedForRowWithIndexPath, "It should've called the orginal function")
    }

    func testCanFocusRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var canFocusRowAtIndexPath: Bool! = false
            var expected: Bool! = false
            @objc
            func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                canFocusRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //Implemented, no ads
        datasource.returnIsAdAtposition = false
        var result = subject?.tableView(tableView, canFocusRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canFocusRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canFocusRowAtIndexPath function we should return the value its returning.")

        mockedDelegate.canFocusRowAtIndexPath = false
        datasource.isAdAtpositionCalled = false

        //We have ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, canFocusRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "return value should be true since we have an ad.")

        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //Not implemented and no ads means true
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, canFocusRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "Return true since we the delegate hasn't got this function implemented.")
    }

    func testDidDeselectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didDeselectRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
                didDeselectRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        //We don't have an ad
        subject?.tableView(tableView, didDeselectRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        datasource.returnIsAdAtposition = false
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didDeselectRowAtIndexPath, "It should've called the orginal function")
    }

    func testDidEndDisplayingCellxPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingCell: Bool! = false
            @objc
            func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
                didEndDisplayingCell = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        //We don't have an ad
        subject?.tableView(tableView, didEndDisplayingCell: uitableviewcell, forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndDisplayingCell, "It should have called the orginal function")
        mockedDelegate.didEndDisplayingCell = false

        //We have ad
        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, didEndEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didEndDisplayingCell == false, "It should NOT have called the orginal function")
    }

    func testDidEndDisplayingFooterView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingFooterView: Bool! = false
            @objc
            func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
                didEndDisplayingFooterView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        subject?.tableView(tableView, didEndDisplayingFooterView: uitableviewcell, forSection: 1)
        XCTAssert(mockedDelegate.didEndDisplayingFooterView, "It should've called the orginal function")
    }

    func testDidEndEditingRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndEditingRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath?) {
                didEndEditingRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        //We don't have an ad
        subject?.tableView(tableView, didEndEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndEditingRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didEndEditingRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, didEndEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didEndEditingRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidEndDisplayingHeaderView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didEndDisplayingHeaderView: Bool! = false
            @objc
            func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
                didEndDisplayingHeaderView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        //We don't have an ad
        subject?.tableView(tableView, didEndDisplayingHeaderView: uitableviewcell, forSection: 1)
        XCTAssert(mockedDelegate.didEndDisplayingHeaderView, "It should've called the orginal function")
    }

    func testCanPerformAction() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var canPerformAction: Bool! = false
            var expected: Bool! = false
            @objc
            func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
                canPerformAction = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        var result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0), withSender: nil)
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canPerformAction, "It should have called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canPerformAction function we should return the value its returning.")
        mockedDelegate.canPerformAction = false

        //We have ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0), withSender: nil)
        XCTAssert(mockedDelegate.canPerformAction == false, "It should NOT have called the orginal function")
        XCTAssert(result == true, "If it is an ad return true")

        //We don't have an ad and its not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //Not implemented and no ads means true
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0), withSender: nil)
        XCTAssert(result == true, "Default value is true. Not implemented")
    }

    func testDidHighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didHighlightRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
                didHighlightRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        subject?.tableView(tableView, didHighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didHighlightRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didHighlightRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, didHighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didHighlightRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidUnhighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUnhighlightRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
                didUnhighlightRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        subject?.tableView(tableView, didUnhighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didUnhighlightRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didUnhighlightRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        subject?.tableView(tableView, didUnhighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.didUnhighlightRowAtIndexPath == false, "It should NOT have called the orginal function")
    }

    func testDidUpdateFocusInContext() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUpdateFocusInContext: Bool! = false
            @objc
            func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
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
            var editActionsForRowAtIndexPath: Bool! = false
            var expected: [UITableViewRowAction] = [UITableViewRowAction(), UITableViewRowAction()]
            @objc
            func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
                editActionsForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        var result = subject?.tableView(tableView, editActionsForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.editActionsForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the editActionsForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.editActionsForRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, editActionsForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.editActionsForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == nil, "When it is an ad. return nil")


        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //We don't have an ad and its not implemented
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, editActionsForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == nil, "Default value is nil. Not implemented")
    }

    func testEditingStyleForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var editingStyleForRowAtIndexPath: Bool! = false
            var expected: UITableViewCellEditingStyle = UITableViewCellEditingStyle.Insert
            @objc
            func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
                editingStyleForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        var result = subject?.tableView(tableView, editingStyleForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.editingStyleForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the editingStyleForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.editingStyleForRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, editingStyleForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.editingStyleForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == UITableViewCellEditingStyle.None, "When it is an ad. return nil")


        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //We don't have an ad and its not implemented
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, editingStyleForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == UITableViewCellEditingStyle.None, "Default value is nil. Not implemented")
    }

    func testEstimatedHeightForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(1337)
            var estimatedHeightForFooterInSection: Bool! = false
            @objc
            func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
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

        //Not implemented
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
            func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
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

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, estimatedHeightForHeaderInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the estimatedHeightForFooterInSection function we should return the value its returning.")
    }

    func testEstimatedHeightForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var estimatedHeightForRowAtIndexPath: Bool! = false
            var expected: CGFloat = CGFloat(188)
            @objc
            func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
                estimatedHeightForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        var result = subject?.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.estimatedHeightForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the estimatedHeightForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.estimatedHeightForRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.estimatedHeightForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == UITableViewAutomaticDimension, "When it is an ad. return nil")


        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //We don't have an ad and its not implemented
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Default value is nil. Not implemented")
    }

    func testHeightForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = CGFloat(1337)
            var heightForFooterInSection: Bool! = false
            @objc
            func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, heightForFooterInSection: 0)
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForFooterInSection function we should return the value its returning.")
    }

    func testIndentationLevelForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var indentationLevelForRowAtIndexPath: Bool! = false
            var expected: Int = 123//This is magic ~ Harry Potter.
            @objc
            func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
                indentationLevelForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        //We don't have an ad
        var result = subject?.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.indentationLevelForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result! == mockedDelegate.expected, "Since the delegate has implemented the indentationLevelForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.indentationLevelForRowAtIndexPath = false

        //We have an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.indentationLevelForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == -1, "When it is an ad. return nil")


        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        //We don't have an ad and its not implemented
        datasource.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == -1, "Default value is nil. Not implemented")
    }

    func testPerformAction() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var performAction: Bool! = false
            @objc
            func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
                performAction = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, performAction: Selector(), forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0), withSender: nil)
        XCTAssert(mockedDelegate.performAction, "It should've called the orginal function")
    }

    func testShouldHighlightRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldHighlightRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                shouldHighlightRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldHighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.shouldHighlightRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldHighlightRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldHighlightRowAtIndexPath = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldHighlightRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldHighlightRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldIndentWhileEditingRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldIndentWhileEditingRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                shouldIndentWhileEditingRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldIndentWhileEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.shouldIndentWhileEditingRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldIndentWhileEditingRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldIndentWhileEditingRowAtIndexPath = false

        //Is an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, shouldIndentWhileEditingRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == true, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        datasource.returnIsAdAtposition = false
        datasource.isAdAtpositionCalled = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldIndentWhileEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldIndentWhileEditingRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldShowMenuForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = true
            var shouldShowMenuForRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
                shouldShowMenuForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, shouldShowMenuForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.shouldShowMenuForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the shouldShowMenuForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldShowMenuForRowAtIndexPath = false

        //Is an ad
        datasource.returnIsAdAtposition = true
        result = subject?.tableView(tableView, shouldShowMenuForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == true, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(datasource.isAdAtpositionCalled, "The function checked if it was an ad.")
        datasource.returnIsAdAtposition = false
        datasource.isAdAtpositionCalled = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldShowMenuForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "Since the delegate has implemented the shouldShowMenuForRowAtIndexPath function we should return the value its returning.")
    }

    func testWillSelectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected = NSIndexPath(forItem: 123, inSection: 144)
            var willSelectRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
                willSelectRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, willSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.willSelectRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.willSelectRowAtIndexPath = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = NSIndexPath(forItem: 1, inSection: 0)
        result = subject?.tableView(tableView, willSelectRowAtIndexPath: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
    }

    func testShouldUpdateFocusInContext() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: Bool! = false
            var shouldUpdateFocusInContext: Bool! = false
            @objc
            func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
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

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, shouldUpdateFocusInContext: UITableViewFocusUpdateContext())
        XCTAssert(result == true, "Since the delegate has implemented the willSelectRowAtIndexPath function we should return the value its returning.")
    }

    func testTargetIndexPathForMoveFromRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: NSIndexPath! = NSIndexPath(forItem: 10, inSection: 123)
            var shouldUpdateFocusInContext: Bool! = false
            @objc
            func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
                shouldUpdateFocusInContext = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0), toProposedIndexPath: NSIndexPath(forItem: 123, inSection: 10))

        XCTAssert(mockedDelegate.shouldUpdateFocusInContext, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the targetIndexPathForMoveFromRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.shouldUpdateFocusInContext = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = NSIndexPath(index: 1)
        result = subject?.tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0), toProposedIndexPath: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the targetIndexPathForMoveFromRowAtIndexPath function we should return the value its returning.")
    }


    func testTitleForDeleteConfirmationButtonForRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: String! = "a test"
            var titleForDeleteConfirmationButtonForRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
                titleForDeleteConfirmationButtonForRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))

        XCTAssert(mockedDelegate.titleForDeleteConfirmationButtonForRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the titleForDeleteConfirmationButtonForRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.titleForDeleteConfirmationButtonForRowAtIndexPath = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        result = subject?.tableView(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == nil, "Since the delegate has implemented the titleForDeleteConfirmationButtonForRowAtIndexPath function we should return the value its returning.")
    }

    func testViewForFooterInSection() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var didUpdateFocusInContext: Bool! = false
            var expected: UIView! = UIView()
            @objc
            func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
            var willBeginEditingRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
                willBeginEditingRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, willBeginEditingRowAtIndexPath: NSIndexPath(forItem: 123, inSection: 10))
        XCTAssert(mockedDelegate.willBeginEditingRowAtIndexPath, "It should've called the orginal function")
    }

    func testWillDeselectRowAtIndexPath() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var expected: NSIndexPath! = NSIndexPath(forItem: 10, inSection: 123)
            var willDeselectRowAtIndexPath: Bool! = false
            @objc
            func tableView(tableView: UITableView, willDeselectRowAtIndexPath sourceIndexPath: NSIndexPath) -> NSIndexPath? {
                willDeselectRowAtIndexPath = true
                return expected
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        var result = subject?.tableView(tableView, willDeselectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))

        XCTAssert(mockedDelegate.willDeselectRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the willDeselectRowAtIndexPath function we should return the value its returning.")
        mockedDelegate.willDeselectRowAtIndexPath = false

        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2

        let expected = NSIndexPath(index: 1)
        result = subject?.tableView(tableView, willDeselectRowAtIndexPath: expected)
        XCTAssert(result == expected, "Since the delegate has implemented the willDeselectRowAtIndexPath function we should return the value its returning.")
    }

    func testWillDisplayCell() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willDisplayCell: Bool! = false
            @objc
            func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
                willDisplayCell = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        subject?.tableView(tableView, willDisplayCell: uitableviewcell, forRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.willDisplayCell, "It should've called the orginal function")
    }

    func testWillDisplayFooterView() {
        class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
            var willDisplayFooterView: Bool! = false
            @objc
            func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
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
            func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
                willDisplayHeaderView = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate

        subject?.tableView(tableView, willDisplayHeaderView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)), forSection: 123)
        XCTAssert(mockedDelegate.willDisplayHeaderView, "It should've called the orginal function")
    }
}
