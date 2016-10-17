//
//  NativeAdCellTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 15/09/16.
//
//

import XCTest
@testable import PocketMediaNativeAds

class NativeAdCellTest: XCTestCase {

    var subject: NativeAdCell!

    override func setUp() {
        super.setUp()

        let bundle = PocketMediaNativeAdsBundle.loadBundle()!
        var nib = bundle.loadNibNamed("NativeAdView", owner: nil, options: nil)!.first!
        subject = nib as! NativeAdCell
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAwakeFromNib() {
        //subject.installButton
        let iButton = subject.installButton!
//        XCTAssert(CGColorEqualToColor(iButton.layer.borderColor, subject.tintColor.CGColor))
        XCTAssert(iButton.layer.borderWidth == 1)
        XCTAssert(iButton.layer.masksToBounds == true)
        XCTAssert(iButton.titleLabel?.baselineAdjustment == .AlignCenters)
        XCTAssert(iButton.titleLabel?.textAlignment == .Center)
//        XCTAssert(iButton.titleLabel?.minimumScaleFactor == 0.1)

        let color = UIColor(red: 17.0 / 255.0, green: 147.0 / 255.0, blue: 67.0 / 255.0, alpha: 1)
        //iButton.setTitleColor(color, forState: .Normal)
        XCTAssert(CGColorEqualToColor(iButton.layer.borderColor!, color.CGColor))
        XCTAssert(iButton.titleEdgeInsets == UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        XCTAssert(iButton.titleLabel?.minimumScaleFactor == 0.50)
        XCTAssert(iButton.titleLabel?.adjustsFontSizeToFitWidth == true)
//        if let image = adImage {
//            iButton.layer.cornerRadius = CGRectGetWidth(image.frame) / 20
//            image.layer.cornerRadius = CGRectGetWidth(image.frame) / 10
//            image.layer.masksToBounds = true
//        }

    }

}
