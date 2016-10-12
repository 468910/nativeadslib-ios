//
//  NativeAdTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

open class MockOpener: NativeAdOpenerProtocol {
	fileprivate (set) var loadCalled: Bool = false

	@objc
	open func load(_ adUnit: NativeAd) {
		loadCalled = true
	}

	@objc
	open func didOpenBrowser(_ url: URL) {

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

		data.removeObject(forKey: "campaign_name")
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
		data.removeObject(forKey: "click_url")
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
		data.removeObject(forKey: "campaign_description")
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
		data.removeObject(forKey: "id")
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

			if let expectedUrl = URL(string: expected) {
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
            XCTAssertTrue(ad.images[EImageType.hqIcon]!.url.isEqual(URL(string: "http://google.co.uk/")!))
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
			XCTAssertTrue(ad.description == "NativeAd.LOVOO: Optional(http://offerwall.beta.pmgbrain.com/save-click.php?campaign=12486&impression=13829453&token=1234)")
			XCTAssertTrue(ad.debugDescription == "NativeAd.LOVOO: Optional(http://offerwall.beta.pmgbrain.com/save-click.php?campaign=12486&impression=13829453&token=1234)")
            Logger.debug("test: \(ad.description)")
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
