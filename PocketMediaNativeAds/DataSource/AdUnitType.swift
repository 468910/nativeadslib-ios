//
//  AdUnitType.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//
import Foundation

@objc
public enum AdUnitType: Int {
    case standard
    case dynamic
    case big
    case custom
    
    var nibName : String {
        switch self {
            case .standard: return "StandardAdUnitTableViewCell";
            case .dynamic: return "DynamicAdUnitTableViewCell";
            case .big: return "BigNativeAdTableViewCell";
            case .custom: return "CustomAdCell";
        }
    }
}
