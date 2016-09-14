//
//  NativeAdTableViewDelegateTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import XCTest
import UIKit

//class NativeAdTableViewDelegateTest: XCTestCase {
//
//    var viewController: TableViewController!
//    
//    override func setUp() {
//        super.setUp()
////        Logger.debug("test")
////        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
////        viewController = storyBoard.instantiateViewControllerWithIdentifier("TableViewController") as! TableViewController
////        Logger.debug("test")
////        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
////    func testTableView() {
////        NSLog("Test123")
////        XCTAssert(true)
////    }
//    
//}


class mockedUITableViewDelegate: NSObject, UITableViewDelegate {
    
}

class mockedNativeAdTableViewDataSource: NativeAdTableViewDataSource {
    
}

class mockedUIViewController: UIViewController {
    
}

class mockedNativeAdStream: NativeAdStream {
    
    var returnIsAdAtposition:Bool = false
    
    override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        if returnIsAdAtposition {
            do {
                let ad = try NativeAd(adDictionary: testHelpers.getNativeAdData(), adPlacementToken: "test")
                return ad
            } catch {
                Logger.debug("isAdAtposition could not return NativeAd")
            }
        }
        return nil
    }
}

class NativeAdTableViewDelegateTest: XCTestCase {

    var tableViewDataSource: ExampleTableViewDataSource?
    
    var subject: NativeAdTableViewDelegate!
    var datasource: NativeAdTableViewDataSource!
    var adStream: NativeAdStream!
    var controller: mockedUIViewController!
    var delegate: UITableViewDelegate!
    
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        
        controller = mockedUIViewController(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
        delegate = mockedUITableViewDelegate()
        
        //These 3 lines are directly from the example app
        tableViewDataSource = ExampleTableViewDataSource()
        tableViewDataSource?.loadLocalJSON()
        tableView.dataSource = tableViewDataSource
        
        tableView.delegate = delegate
        adStream = NativeAdStream(controller: controller, mainView: tableView)
        
        datasource = mockedNativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: adStream)
        subject = NativeAdTableViewDelegate(datasource: datasource, controller: controller, delegate: delegate)
    
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//    func testdidSelectRowAtIndexPath() {
//        subject?.tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(index: 0))
//        XCTAssert(true)
//        //Check if called
//        
//    }

}
