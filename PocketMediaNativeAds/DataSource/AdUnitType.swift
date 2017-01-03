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
 */
@objc
public enum AdUnitType: Int {
    /// for regular UITableViewCell ads.
    case standard
    /// for UITableViewCell ads where an UI will be provided.
    case dynamic
    /// for larger UITableViewCell ads.
    case big
    /// for ads where the implementation will be provided.
    case custom
    /**
     Returns a string of the nib
     */
    var nibName: String {
        switch self {
        case .standard: return "StandardAdUnitTableViewCell"
        case .dynamic: return "DynamicAdUnitTableViewCell"
        case .big: return "BigNativeAdTableViewCell"
        case .custom: return "CustomAdCell"
        }
    }
}
