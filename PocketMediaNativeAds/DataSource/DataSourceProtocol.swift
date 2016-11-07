//
//  DataSourceProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

@objc
public protocol DataSourceProtocol {
    func onAdRequestSuccess(_ newAds: [NativeAd])
    func getNativeAdListing(_ indexPath: IndexPath) -> NativeAdListing?
}

public protocol NativeAdTableViewDataSourceProtocol: DataSourceProtocol {
    func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int
}
