//
//  IndexRowNormalizerTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 09/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class FakeNativeAdTableViewDataSource: NativeAdTableViewDataSourceProtocol {

	// Returns the amount of rows in a given section.
	func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int {
		switch (section) {
			case 0: return 10
			case 1: return 20
			case 2: return 30
			default: return 0
		}

	}

	@objc
	func getTruePositionInDataSource(indexPath: NSIndexPath) -> Int {
		return 0
	}

	@objc
	func onUpdateDataSource() {

	}

	@objc
	func numberOfElements() -> Int {
		return 1
	}

}

class IndexRowNormalizerTest: XCTestCase {

	var dataSource: FakeNativeAdTableViewDataSource?

	override func setUp() {
		super.setUp()
		dataSource = FakeNativeAdTableViewDataSource()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testIndexRowNormalizer() {
		var index = 10,
			previousSection = 0,
			currentSection = previousSection + 1,
			numOfRowsInPreviousSection = dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: previousSection),
			expectedIndexForRow = index + numOfRowsInPreviousSection - 1

		var result = IndexRowNormalizer.getTruePositionForIndexPath(NSIndexPath(forItem: index, inSection: currentSection), datasource: dataSource!)
		XCTAssert(expectedIndexForRow == result, "getTruePositionForIndexPath should add 9. Because the index starts from 10 - 1")

		index = 10
		previousSection = 1
		currentSection = previousSection + 1
		numOfRowsInPreviousSection = dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: previousSection)
		numOfRowsInPreviousSection += dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: (previousSection - 1))
		expectedIndexForRow = index + numOfRowsInPreviousSection - 1

		result = IndexRowNormalizer.getTruePositionForIndexPath(NSIndexPath(forItem: index, inSection: currentSection), datasource: dataSource!)
		XCTAssert(expectedIndexForRow == result, "getTruePositionForIndexPath should return 10 because its in section 0")
	}

	func testNormalizeIndex66with17AdsShouldReturn49() {
		let result = IndexRowNormalizer.normalize(66, firstAdPosition: 2, adMargin: 4, adsCount: 40)
		XCTAssert(result == 66 - 17, "The normalized index should be 49")

	}

	func testNormalizeIndex66with0AdsShouldReturn66() {
		let result = IndexRowNormalizer.normalize(66, firstAdPosition: 2, adMargin: 4, adsCount: 0)
		XCTAssert(result == 66 - 0, "The normalized index should be 66")

	}

	func testNormalizeIndex66with1AdsShouldReturn65() {
		let result = IndexRowNormalizer.normalize(66, firstAdPosition: 2, adMargin: 4, adsCount: 1)
		XCTAssert(result == 66 - 1, "The normalized index should be 66")
	}

  func testGetCountForSection() {
     let numOfExpectedAds = 10
     let result = IndexRowNormalizer.getNumberOfRowsForSectionIncludingAds(20, totalRowsInSection: 100, firstAdPosition: 4, adMargin: 10, adsCount: 40)
     XCTAssert(result == 20 + numOfExpectedAds)
  }

	func testGetAdsForRange0till20returns5() {
		let result = IndexRowNormalizer.getAdsForRange(0...20, firstAdPosition: 2, adMargin: 4)
		XCTAssert(result == 5, "Ads for range should return 5")
	}

	func testGetAdsForRange0till0returns0() {
		let result = IndexRowNormalizer.getAdsForRange(0...0, firstAdPosition: 2, adMargin: 4)
		XCTAssert(result == 0, "Ads for range should return 0")
	}

	func testGetAdsForRange0till2returns2() {
		let result = IndexRowNormalizer.getAdsForRange(0...2, firstAdPosition: 2, adMargin: 4)
		XCTAssert(result == 1, "Ads for range should return 1")
	}

}
