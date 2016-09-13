//
//  NativeAdViewBinderProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 01/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import UIKit

protocol NativeAdViewBinderProtocol {
	func configureAdView(nativeAd: NativeAd)
	func configureAdView(nativeAd: NativeAd, viewController: UIViewController)
}