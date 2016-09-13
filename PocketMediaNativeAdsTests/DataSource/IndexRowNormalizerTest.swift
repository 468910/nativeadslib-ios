//
//  IndexRowNormalizerTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 09/09/16.
//
//

import XCTest

class FakeNativeAdTableViewDataSource: NativeAdTableViewDataSourceProtocol {
	func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0 : return 1337
        case 1 : return 1337
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
        var expected = 1337 + 10 - 1
        var index = NSIndexPath(forItem: 10, inSection: 1)
        var result = IndexRowNormalizer.getTruePosistionForIndexPath(index, datasource: dataSource!)
        XCTAssert(expected == result, "getTruePosistionForIndexPath should add 9. Because the index starts from 10 - 1")
        
        expected = 10
        index = NSIndexPath(forItem: 10, inSection: 0)
        result = IndexRowNormalizer.getTruePosistionForIndexPath(index, datasource: dataSource!)
        XCTAssert(expected == result, "getTruePosistionForIndexPath should return 10 because its in section 0")
	}
    
    func testNormalize() {
        let expected = 1344
        let index = NSIndexPath(forItem: 10, inSection: 1)
        
        let pos = IndexRowNormalizer.getTruePosistionForIndexPath(index, datasource: dataSource!)
        let result = IndexRowNormalizer.normalize(pos, firstAdPosition: 0, adMargin: 1, adsCount: 2)
        XCTAssert(expected == result, "normalize should return 1344 because ...")
    }
    
}
