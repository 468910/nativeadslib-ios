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
	public func load(adUnit: NativeAd) {
		loadCalled = true
		adUnit.openAdUrlInForeground()
	}

	@objc
	public func didOpenBrowser(url: NSURL) {

	}
}

class NativeAdTest: XCTestCase {
	var data: NSMutableDictionary!

	override func setUp() {
		super.setUp()
		data = testHelpers.getNativeAdData()!
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testInitCampaign_name() {
        
		data.removeObjectForKey("campaign_name")
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
		data.removeObjectForKey("click_url")
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
		data.removeObjectForKey("campaign_description")
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
		data.removeObjectForKey("id")
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

		// Always prefer default_icon
		let expected = "http://google.com/"
		data["default_icon"] = expected
		data["campaign_image"] = "http://bing.com/"// Don't prefer bing now ;)
		do {
			let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")

			if let expectedUrl = NSURL(string: expected) {
				XCTAssert(ad.campaignImage.isEqual(expectedUrl))
			} else {
				XCTFail("Couldn't get the expected url")
			}

		} catch {
			XCTFail("No exceptions should've been thrown")
		}

	}

	func testInitImages() {
        do {
            let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
            XCTAssertTrue(ad.images[0].url == "http://offerwall.12trackway.com/image-world/3632c32ca698501d01f8c3971092ad56c1ce507812e379c35c510cfab382f08e8f644f1f0c9bc1a6209d317317ad1610ba583c008efe1823799bf04876ae3ed666c22f2e4552fc515868ae68ee6816d6d7d3dcbaca4970f3e1aa2b1b193ff164c47d6a4e9657f4cffa7143fdd20d9cb094df9645349d0b2a00cb7834060aebfd5e560e54dfb5fea8daf5c3f3438e1bde1e8ed0458c92de429fd07ea046d911ea18b7241bc8477682cdf5e5d744afc13f74f210b058110d67b98f36c190c68e03a59e81bd4c8b6c172cde16e26a2dd88c.jpg")
        } catch {
            XCTFail("Unexpected exception thrown")
        }
        
        data["images"] = "Not images"
		do {
			try NativeAd(adDictionary: data, adPlacementToken: "none")
			XCTFail("Exception should have been thrown")
		} catch NativeAdsError.InvalidAdNoImages {
			XCTAssertTrue(true)
		} catch {
			XCTFail("Wrong exception thrown")
		}
	}

	func testDescriptions() {
		do {
			let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
			XCTAssertTrue(ad.description == "NativeAd.Travel Blast!: http://offerwall.12trackway.com/save-click.php?campaign=277684&impression=76281078&token=1234")
			XCTAssertTrue(ad.debugDescription == "NativeAd.Travel Blast!: http://offerwall.12trackway.com/save-click.php?campaign=277684&impression=76281078&token=1234")
		} catch {
			XCTFail("Unexpected exception thrown")
		}
	}

	func testOpenAdUrl() {
		do {
			let ad = try NativeAd(adDictionary: data, adPlacementToken: "none")
			let opener = MockOpener()
			ad.openAdUrl(opener)
			XCTAssertTrue(opener.loadCalled)
		} catch {
			XCTFail("Unexpected exception thrown")
		}

	}

}
