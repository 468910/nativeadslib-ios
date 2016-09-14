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

}
