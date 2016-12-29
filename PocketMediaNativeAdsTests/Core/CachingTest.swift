//
//  CachingTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 16/09/16.
//
//

import Foundation
import XCTest

@testable import PocketMediaNativeAds

// class CachingTest: XCTestCase {
//
//    var subject: UIView!
//    var url: NSURL!
//
//    override func setUp() {
//        subject = UIView()
//        url = NSURL(string: "https://placehold.it/350x150")
//        super.setUp()
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testSetupWebView() {
//        // Cache the image
//        if let campaignImage = url.cachedImage {
//            // Cached: set immediately.
//            image.image = campaignImage
//            image.alpha = 1
//        } else {
//            // Not cached, so load then fade it in.
//            image.alpha = 0
//            nativeAd.campaignImage.fetchImage { downloadedImage in
//                // Check the cell hasn't recycled while loading.
//                if nativeAd.campaignImage == downloadedImage {
//                    image.image = downloadedImage
//                    image.reloadInputViews()
//                    UIView.animateWithDuration(0.3) {
//                        image.alpha = 1
//                        image.setNeedsDisplay()
//                    }
//                }
//            }
//        }
//    }
// }
