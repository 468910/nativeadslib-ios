//
//  HTTPClient.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 07/09/16.
//
//

import Foundation

public typealias DataTaskResult = (NSData?, NSURLResponse?, NSError?) -> Void

public protocol URLSessionProtocol {
	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult)
		-> NSURLSessionDataTask
}

extension NSURLSession: URLSessionProtocol { }