//
//  DataSourceProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

@objc
public protocol DataSourceProtocol : DatasourceNormalizerProtocol {
	func onUpdateDataSource()
	func numberOfElements() -> Int
    func attachAdStream(adStream : NativeAdStream)
}

public protocol NativeAdTableViewDataSourceProtocol : DataSourceProtocol {
    func getNumberOfRowsInSection(numberOfRowsInSection section: Int) -> Int
}