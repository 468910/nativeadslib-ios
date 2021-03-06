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
    var limit: UInt! = 0
    override func retrieveAds(_ limit: UInt, imageType: EImageType = EImageType.allImages) {
        self.limit = limit
    }
}

class mocked2NativeAdsConnection: NativeAdsConnectionDelegate {

    @objc
    func didReceiveError(_ error: Error) {
    }

    @objc
    func didReceiveResults(_ nativeAds: [NativeAd]) {
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

        /*
         subject.datasource.adPositionOffset = 1
         subject.didReceiveResults(ads)
         XCTAssert(subject.datasource.ads.count == ads.count, "Ads should've been added")

         //Higher adPositionOffset than we have ads
         subject.datasource.adPositionOffset = 100
         subject.didReceiveResults(ads)
         XCTAssert(subject.datasource.ads.count == 0, "No Ads shoud've been added")

         subject.datasource.adPositionOffset = 1
         subject.adsPositions = [1, 0, 3]
         XCTAssert(subject.adsPositions! == [0, 1, 3], "It should sort the adsPositions")
         subject.didReceiveResults(ads)
         XCTAssert((subject.datasource.ads) != nil)
        */
    }

    func testRequestAds() {
        let expected = UInt(80)
        subject.requestAds(expected)
        XCTAssert(requester.limit == expected, "The sent limit should be passed along to the requestAds function inside the requester.")
    }
}
