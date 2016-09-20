//
//  NativeAdTableViewDatasource.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 20/09/16.
//
//

import XCTest
import UIKit

class baseMockedNativeAdDataSource: NativeAdTableViewDataSource {
    var returnIsAdAtposition: Bool = false
    var isAdAtpositionCalled: Bool = false
    var isGetAdCellForTableViewCalled: Bool = false
    var ad: NativeAd?
    
    override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
        isAdAtpositionCalled = true
        if returnIsAdAtposition {
            return ad
        }
        return nil
    }
    
    override func getAdCellForTableView(nativeAd: NativeAd) -> UITableViewCell {
        isGetAdCellForTableViewCalled = true
        return NativeAdCell()
    }
    
    func setupAd() {
        var data = testHelpers.getNativeAdData()!
        self.ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")
        
    }
}

class nonImplementedDatasource: NSObject, UITableViewDataSource {
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
    
    var subject: baseMockedNativeAdDataSource!
    var originalDataSource: UITableViewDataSource!
    var tableView: UITableView!
    var controller: UIViewController!
    
    override public func setUp() {
        super.setUp()
    }
    
    func setUpDataSource(mockedDatasource: UITableViewDataSource) {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
        controller.view = tableView
        
        tableView.delegate = baseMockedDelegate()
        
        originalDataSource = mockedDatasource
        if originalDataSource.dynamicType == ExampleTableViewDataSource.self {
            (originalDataSource as! ExampleTableViewDataSource).loadLocalJSON()
        }
        tableView.dataSource = originalDataSource
        
        subject = baseMockedNativeAdDataSource(controller: controller, tableView: tableView)
        
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
        subject.returnIsAdAtposition = false
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let result = (originalDataSource as! mockedDatasource).calledCellForRowAtIndexPath
        XCTAssert(result == true, "cellForRowAtIndexPath has been called in the original DataSource")
        
        // Test if NativeAdCell gets returned
        subject.returnIsAdAtposition = true
        subject.setupAd()
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
        
        setUpDataSource(nonImplementedDatasource())
        
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
        
        setUpDataSource(nonImplementedDatasource())
        
        result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")
        
    }
    
    func testCommitEditingStyle() {
        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCalled : Bool = false
            func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
                commitEditingStyleHasBeenCalled = true
            }
        }
        /*
         setUpDataSource(mockedDataSource())
         subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 1))
         XCTAssert((originalDataSource as! mockedDataSource!).commitEditingStyleHasBeenCalled == true, "Called original commitEditingStyle")
         */
        
        setUpDataSource(nonImplementedDatasource())
        if (originalDataSource.respondsToSelector(Selector("tableView:commitEditingStyle"))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
        
        
    }
    
}
