//
//  NativeAdStreamTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class mocked2UIViewController: UIViewController {

}

class mocked2UITableView: UITableView {

}

class mocked2NativeAdsRequest: NativeAdsRequest {

}

class mocked2NativeAdsConnection: NativeAdsConnectionDelegate {

    @objc
    func didReceiveError(error: NSError) {

    }

    @objc
    func didReceiveResults(nativeAds: [NativeAd]) {

    }
}

class NativeAdStreamTest: XCTestCase {

    var subject: NativeAdStream!
    var controller: mocked2UIViewController!
    var view: mocked2UITableView!
    var requester: mocked2NativeAdsRequest!

    override func setUp() {
        super.setUp()
        controller = mocked2UIViewController()
        view = mocked2UITableView()

        let tableViewDataSource = ExampleTableViewDataSource()
        tableViewDataSource.loadLocalJSON()
        view.dataSource = tableViewDataSource

        requester = mocked2NativeAdsRequest(adPlacementToken: "test123", delegate: mocked2NativeAdsConnection())

        subject = NativeAdStream(controller: controller, view: view, adPlacementToken: "test123", requester: requester)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitRegisterNib() {
        class mockedUITableView: UITableView {
            var registerNibCalled: Bool = false
            override func registerNib(nib: UINib?, forCellReuseIdentifier identifier: String) {
                registerNibCalled = true
            }
        }

        let tableView = mockedUITableView()
        let tableViewDataSource = ExampleTableViewDataSource()
        tableViewDataSource.loadLocalJSON()
        tableView.dataSource = tableViewDataSource

        subject = NativeAdStream(controller: controller, view: tableView, adPlacementToken: "test123", customXib: UINib(), requester: requester)
        XCTAssert(tableView.registerNibCalled, "registerNib called")
    }

    func testSetAdMargin() {
        subject.setAdMargin(1)
        XCTAssert(subject.datasource.adMargin == 1, "Setter should set the adMargin within the datasource.")
    }

    func testSetFirstAdPosition() {
        subject.setFirstAdPosition(0)
        XCTAssert(subject.datasource.firstAdPosition == 1, "Setter should set the firstAdPosition within the datasource.")
    }

    func testDidReceiveResults() {
        var ads: [NativeAd] = [NativeAd]()
        for adDict in testHelpers.getNativeAdsData()! {
            do {
                let ad = try NativeAd(adDictionary: adDict, adPlacementToken: "test")
                ads.append(ad)
            } catch {
                XCTFail("Could not make ad")
            }
        }

        subject.datasource.firstAdPosition = 1
        subject.didReceiveResults(ads)
        XCTAssert(subject.datasource.ads.count == ads.count, "Ads should've been added")

        //Higher firstAdPosition than we have ads
        subject.datasource.firstAdPosition = 100
        subject.didReceiveResults(ads)
        XCTAssert(subject.datasource.ads.count == 0, "Ads should've been added")
        
        
        subject.datasource.firstAdPosition = 1
        subject.adsPositions = [1, 0, 3]
        XCTAssert(subject.adsPositions! == [0, 1, 3], "It should sort the adsPositions")
        subject.didReceiveResults(ads)
        //XCTAssert(subject.datasource.ads)
    }
    
}
