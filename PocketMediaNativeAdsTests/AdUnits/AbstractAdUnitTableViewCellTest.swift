//
//  AbstractBigAdUnitTableViewCellTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 15/09/16.
//
//

import XCTest
import UIKit
@testable import PocketMediaNativeAds

class AbstractAdUnitTableViewCellTest: XCTestCase {
    var subject: PocketMediaNativeAds.AbstractAdUnitTableViewCell!

    override func setUp() {
        super.setUp()

        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        let nib = bundle.loadNibNamed("NativeAdCell", owner: nil, options: nil)
        subject = nib!.first as! PocketMediaNativeAds.AbstractAdUnitTableViewCell
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAwakeFromNib() {
        if let ad_description = subject.adDescription {
            XCTAssert(ad_description.numberOfLines == 0)
            XCTAssert(ad_description.lineBreakMode == .ByTruncatingTail)
            XCTAssert(ad_description.preferredMaxLayoutWidth != 0)
            XCTAssert(ad_description.preferredMaxLayoutWidth != 0)
        }
        if let title = subject.adTitle {
            XCTAssert(title.numberOfLines == 0)
            XCTAssert(title.lineBreakMode == .ByTruncatingTail)
        }
    }

    func testConfigureAdView() {
        let adDictionary = testHelpers.getNativeAdData()
        do {
            let nativeAd = try PocketMediaNativeAds.NativeAd(adDictionary: adDictionary!, adPlacementToken: "123")
            subject.configureAdView(nativeAd)

            if let title = subject.adTitle {
                title.text = nativeAd.campaignName
            }
            if let description = subject.adDescription {
                description.text = nativeAd.campaignDescription
            }
            if let image = subject.adImage {
                image.setImageFromURL(nativeAd.campaignImage)
            }
        } catch {
            XCTFail("Could not create an instance of nativeAd")
        }
    }
}
