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
	var ad: mockedNativeAd?

	override func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
		isAdAtpositionCalled = true
		if returnIsAdAtposition {
			return ad
		}
		return nil
	}
}

class baseMockedDelegate: NSObject, UITableViewDelegate {

}

public class NativeAdTableViewDatasourceTest: XCTestCase {

	var subject: baseMockedNativeAdDataSource!
	var originalDataSource: UITableViewDataSource!
	var tableView: UITableView!

	override public func setUp() {
		super.setUp()
	}

	func setUpDataSource(mockedDatasource: UITableViewDataSource) {
		var controller = UIViewController()
		tableView = UITableView(frame: CGRect(), style: UITableViewStyle.Plain)
		controller.view = tableView

		tableView.delegate = baseMockedDelegate()

		originalDataSource = mockedDatasource
		(originalDataSource as! ExampleTableViewDataSource).loadLocalJSON()
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
      
      

	}

}