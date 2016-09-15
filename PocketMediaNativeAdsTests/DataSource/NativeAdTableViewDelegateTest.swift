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
    
}

class mockedUIViewController: UIViewController {
    
}

class mockedNativeAd: NativeAd {
    var openAdUrlCalled:Bool = false
    
    override func openAdUrl(opener: NativeAdOpenerProtocol) {
        openAdUrlCalled = true
    }
}

class mockedNativeAdStream: NativeAdStream {
    
    var returnIsAdAtposition:Bool = false
    var isAdAtpositionCalled:Bool = false
    var ad:mockedNativeAd?
    
    override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        isAdAtpositionCalled = true
        if returnIsAdAtposition {
            return ad
        }
        return nil
    }
}

class NativeAdTableViewDelegateTest: XCTestCase {

    var tableViewDataSource: ExampleTableViewDataSource?
    
    var subject: NativeAdTableViewDelegate!
    var datasource: NativeAdTableViewDataSource!
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
        tableViewDataSource?.loadLocalJSON()
        tableView.dataSource = tableViewDataSource
        
        tableView.delegate = self.delegate
        adStream = mockedNativeAdStream(controller: controller, mainView: tableView)
        
        do {
            adStream.ad = try mockedNativeAd(adDictionary: testHelpers.getNativeAdData(), adPlacementToken: "test")
        } catch {
            XCTFail("Could not create an instance of NativeAd")
        }
        
        datasource = mockedNativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: adStream)
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
        
        adStream.returnIsAdAtposition = false
        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didSelectRowAtIndexPath = false
        adStream.ad!.openAdUrlCalled = false
        
        adStream.returnIsAdAtposition = true
        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(mockedDelegate.didSelectRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(adStream.ad!.openAdUrlCalled, "It should've called our function")
        mockedDelegate.didSelectRowAtIndexPath = false
        adStream.ad!.openAdUrlCalled = false
        adStream.returnIsAdAtposition = false
        
        //If adsteam is weak + optional
//        subject.datasource.adStream = nil
//        adStream.returnIsAdAtposition = true
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
        let mockedDelegate2 = self.delegate as! mockedUITableViewDelegate2
        
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
        adStream.isAdAtpositionCalled = false
        
        //Is an ad
        adStream.returnIsAdAtposition = true
        result = subject?.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        adStream.returnIsAdAtposition = false
        adStream.isAdAtpositionCalled = false
        
        //Not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2
        
        adStream.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
        XCTAssert(result == UITableViewAutomaticDimension, "Since the delegate has implemented the heightForHeaderInSection function we should return the value its returning.")
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        
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
        
        adStream.returnIsAdAtposition = false
        subject?.tableView(tableView, accessoryButtonTappedForRowWithIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.AccessoryButtonTappedForRowWithIndexPath, "It should've called the orginal function")
        mockedDelegate.AccessoryButtonTappedForRowWithIndexPath = false
        adStream.isAdAtpositionCalled = false
        
        adStream.returnIsAdAtposition = true
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
        adStream.returnIsAdAtposition = false
        var result = subject?.tableView(tableView, canFocusRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canFocusRowAtIndexPath, "It should've called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canFocusRowAtIndexPath function we should return the value its returning.")
        
        mockedDelegate.canFocusRowAtIndexPath = false
        adStream.isAdAtpositionCalled = false
        
        //We have ad
        adStream.returnIsAdAtposition = true
        result = subject?.tableView(tableView, canFocusRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == true, "return value should be true since we have an ad.")
    
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2
        
        //Not implemented and no ads means true
        adStream.isAdAtpositionCalled = false
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
        adStream.returnIsAdAtposition = false
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
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
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndDisplayingCell, "It should have called the orginal function")
        mockedDelegate.didEndDisplayingCell = false
        
        //We have ad
        adStream.returnIsAdAtposition = true
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
            func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
                didEndEditingRowAtIndexPath = true
            }
        }
        setup2(mockedUITableViewDelegate())
        let mockedDelegate = self.delegate as! mockedUITableViewDelegate
        let uitableviewcell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        //We don't have an ad
        subject?.tableView(tableView, didEndEditingRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.didEndEditingRowAtIndexPath, "It should've called the orginal function")
        mockedDelegate.didEndEditingRowAtIndexPath = false
        
        //We have an ad
        adStream.returnIsAdAtposition = true
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
        XCTAssert(adStream.isAdAtpositionCalled, "The function checked if it was an ad.")
        XCTAssert(mockedDelegate.canPerformAction, "It should have called the orginal function")
        XCTAssert(result == mockedDelegate.expected, "Since the delegate has implemented the canPerformAction function we should return the value its returning.")
        mockedDelegate.canPerformAction = false
        
        //We have ad
        adStream.returnIsAdAtposition = true
        result = subject?.tableView(tableView, canPerformAction: Selector(), forRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0), withSender: nil)
        XCTAssert(mockedDelegate.canPerformAction == false, "It should NOT have called the orginal function")
        XCTAssert(result == true, "If it is an ad return true")
        
        //We don't have an ad and its not implemented
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2
        
        //Not implemented and no ads means true
        adStream.isAdAtpositionCalled = false
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
        adStream.returnIsAdAtposition = true
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
        adStream.returnIsAdAtposition = true
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
        adStream.returnIsAdAtposition = true
        result = subject?.tableView(tableView, editActionsForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(mockedDelegate.editActionsForRowAtIndexPath == false, "It should NOT have called the orginal function")
        XCTAssert(result == nil, "When it is an ad. return nil")
        
        
        class mockedUITableViewDelegate2: NSObject, UITableViewDelegate {}
        setup2(mockedUITableViewDelegate2())
        self.delegate as! mockedUITableViewDelegate2
        
        //We don't have an ad and its not implemented
        adStream.isAdAtpositionCalled = false
        result = subject?.tableView(tableView, editActionsForRowAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        XCTAssert(result == nil, "Default value is nil. Not implemented")
        
    }
    
}
