//
//  AdUnitType.swift
//  PocketMediaNativeAds
//  Types of Ad Units to be handled by the library
//  Created by Iain Munro on 13/09/16.
//
//
import Foundation

/**
 Types of Ad Units to be handled by the library
 - standard: for regular UITableViewCell ads.
 - dynamic: for UITableViewCell ads where an UI will be provided.
 - big: for larger UITableViewCell ads.
 - custom: for ads where the implementation will be provided.
 */
@objc
public enum AdUnitType: Int {
    case standard
    case dynamic
    case big
    case custom

    var nibName: String {
        switch self {
        case .standard: return "StandardAdUnitTableViewCell"
        case .dynamic: return "DynamicAdUnitTableViewCell"
        case .big: return "BigNativeAdTableViewCell"
        case .custom: return "CustomAdCell"
        }
    }
}
