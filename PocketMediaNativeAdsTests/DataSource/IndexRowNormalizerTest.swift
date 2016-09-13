//
//  IndexRowNormalizerTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 09/09/16.
//
//

import XCTest

class FakeNativeAdTableViewDataSource: NativeAdTableViewDataSourceProtocol {
	
    //Returns the amount of rows in a given section.
    func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0 : return 10
        case 1 : return 20
        case 2 : return 30
        default : return 0
        }
        
	}
    
    @objc
    func getTruePosistionInDataSource(indexPath : NSIndexPath) -> Int {
        return 0
    }
    
    @objc
    func onUpdateDataSource() {
        
    }
    
    @objc
    func numberOfElements() -> Int {
        return 1
    }
    
    @objc
    func attachAdStream(adStream : NativeAdStream) {
        
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
        
        var result = IndexRowNormalizer.getTruePosistionForIndexPath( NSIndexPath(forItem: index, inSection: currentSection), datasource: dataSource!)
        XCTAssert(expectedIndexForRow == result, "getTruePosistionForIndexPath should add 9. Because the index starts from 10 - 1")
        
        index = 10
        previousSection = 1
        currentSection = previousSection + 1
        numOfRowsInPreviousSection = dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: previousSection)
        numOfRowsInPreviousSection += dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: (previousSection - 1) )
        expectedIndexForRow = index + numOfRowsInPreviousSection - 1
        
        result = IndexRowNormalizer.getTruePosistionForIndexPath( NSIndexPath(forItem: index, inSection: currentSection), datasource: dataSource!)
        XCTAssert(expectedIndexForRow == result, "getTruePosistionForIndexPath should return 10 because its in section 0")
        Logger.debug("jaja")
	}
    
//    func testNormalize() {
//        var index = 10,
//        amountOfAds = 4,
//        previousSection = 0,
//        currentSection = previousSection + 1,
//        numOfRowsInPreviousSection = dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: previousSection),
//        IndexForRow = index + numOfRowsInPreviousSection - 1,
//        adMargin = 2,
//        firstAdPosition = 2,
//        expected = 1 + IndexForRow - (IndexForRow - firstAdPosition) / adMargin
//        
//        var result = IndexRowNormalizer.normalize(IndexForRow, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: amountOfAds)
//        XCTAssert(expected == result, "normalize should return 1344 because ...")
//        
//        index = 10
//        amountOfAds = 1000
//        previousSection = 0
//        currentSection = previousSection + 1
//        numOfRowsInPreviousSection = dataSource!.getNumberOfRowsInSection(numberOfRowsInSection: previousSection)
//        IndexForRow = index + numOfRowsInPreviousSection - 1
//        adMargin = 2
//        firstAdPosition = 2
//        expected = 1 + IndexForRow - (IndexForRow - firstAdPosition) / adMargin
//        
//        result = IndexRowNormalizer.normalize(IndexForRow, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: amountOfAds)
//        XCTAssert(expected == result, "normalize should return 1344 because ...")
//
//    }
    
}
