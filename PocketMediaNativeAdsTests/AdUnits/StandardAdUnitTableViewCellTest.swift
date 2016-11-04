//
//  NativeAdCellTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 15/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class StandardAdUnitTableViewCellTest: XCTestCase {

    var subject: StandardAdUnitTableViewCell!

    override func setUp() {
        super.setUp()

        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        let nib = bundle.loadNibNamed("StandardAdUnitTableViewCell", owner: nil, options: nil)!.first!
        subject = nib as! StandardAdUnitTableViewCell
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRender() {
        let adDictionary = testHelpers.getNativeAdData()
        var nativeAd: NativeAd?
        do {
            nativeAd = try NativeAd(adDictionary: adDictionary!, adPlacementToken: "123")
        } catch {
            XCTFail("Could not create an instance of nativeAd")
        }

        subject.render(nativeAd!)

        if let title = subject.adTitle {
            title.text = nativeAd!.campaignName
        }
        if let description = subject.adDescription {
            description.text = nativeAd!.campaignDescription
        }
        if let image = subject.adImage {
            image.nativeSetImageFromURL(nativeAd!.campaignImage)
        }

        let iButton = subject.installButton!
        //        XCTAssert(CGColorEqualToColor(iButton.layer.borderColor, subject.tintColor.CGColor))
        XCTAssert(iButton.layer.borderWidth == 1)
        XCTAssert(iButton.layer.masksToBounds == true)
        XCTAssert(iButton.titleLabel?.baselineAdjustment == .AlignCenters)
        XCTAssert(iButton.titleLabel?.textAlignment == .Center)
        //        XCTAssert(iButton.titleLabel?.minimumScaleFactor == 0.1)

        let color = UIColor(red: 17.0 / 255.0, green: 147.0 / 255.0, blue: 67.0 / 255.0, alpha: 1)
        // iButton.setTitleColor(color, forState: .Normal)
        XCTAssert(CGColorEqualToColor(iButton.layer.borderColor!, color.CGColor))
        XCTAssert(iButton.titleEdgeInsets == UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        XCTAssert(iButton.titleLabel?.minimumScaleFactor == 0.50)
        XCTAssert(iButton.titleLabel?.adjustsFontSizeToFitWidth == true)
        //        if let image = adImage {
        //            iButton.layer.cornerRadius = CGRectGetWidth(image.frame) / 20
        //            image.layer.cornerRadius = CGRectGetWidth(image.frame) / 10
        //            image.layer.masksToBounds = true
        //        }

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
}
