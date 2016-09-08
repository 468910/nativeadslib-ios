//
//  NativeAdTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds


public class MockOpener: NativeAdOpenerProtocol {
    private (set) var loadCalled: Bool = false
    
    @objc
    public func load(adUnit : NativeAd) {
        loadCalled = true
        adUnit.openAdUrlInForeground()
    }
    
    @objc
    public func didOpenBrowser(url: NSURL) {
        
    }
}

class NativeAdTest: XCTestCase {
    var data:[String:String] = [:]
    
    override func setUp() {
        super.setUp()
        data = [
            "campaign_name": "tests",
            "click_url": "http://PocketMedia.mobi/lovely/tests",
            "campaign_description": "",
            "id": "123",
            "default_icon": "http://google.co.uk"
        ]
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
 
    func testInitCampaign_name() {
        
        data.removeValueForKey("campaign_name")
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoCampaign {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
        
    }
    
    func testInitClickUrl() {
        data.removeValueForKey("click_url")
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoClickUrl {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
        
        data["click_url"] = "Not a URL"
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoClickUrl {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
    }
    
    func testInitCampaignDescription() {
        data.removeValueForKey("campaign_description")
        do {
            let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTAssertTrue(ad.campaignDescription == "")
        } catch NativeAdsError.InvalidAdNoId {
            XCTFail("Exception should not have been thrown")
        } catch {
            XCTFail("Exception should not have been thrown")
        }
    }
    
    func testInitId() {
        data.removeValueForKey("id")
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoId {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
        data["id"] = "Not a number!"
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoId {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
    }
    
    func testInitImage() {
        data["default_icon"] = "Not a URL"
        data["campaign_image"] = "Not a URL"
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTFail("Exception should have been thrown")
        } catch NativeAdsError.InvalidAdNoImage {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong exception thrown")
        }
        
        data["campaign_image"] = "http://google.co.uk/"
        do {
            try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTAssertTrue(true)
        } catch NativeAdsError.InvalidAdNoId {
            XCTFail("Exception should have been thrown")
        } catch {
            XCTFail("Wrong exception thrown")
        }
        
        //Always prefer default_icon
        let expected = "http://google.com/"
        data["default_icon"] = expected
        data["campaign_image"] = "http://bing.com/"//Don't prefer bing now ;)
        do {
            let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
        
            if let expectedUrl = NSURL(string: expected) {
                XCTAssert( ad.campaignImage.isEqual(expectedUrl) )
            } else {
                XCTFail("Couldn't get the expected url")
            }
            
        } catch {
            XCTFail("No exceptions should've been thrown")
        }
        
    }

    func testDescriptions() {
        do {
            let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTAssertTrue(ad.description == "NativeAd.tests: http://PocketMedia.mobi/lovely/tests")
            XCTAssertTrue(ad.debugDescription == "NativeAd.tests: http://PocketMedia.mobi/lovely/tests")
        }catch {
            XCTFail("Unexpected exception thrown")
        }
    }
    
    func testOpenAdUrl() {
        do {
            let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
            let opener = MockOpener()
            ad.openAdUrl(opener)
            XCTAssertTrue(opener.loadCalled)
        }catch {
            XCTFail("Unexpected exception thrown")
        }
        
    }
    
}
