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
    /// for regular UITableViewCell.
    case tableViewRegular
    /// for larger UITableViewCell.
    //    case tableViewBig
    /// for regular UICollectionItemCell.
    case collectionViewRegular
    /// When the xib is provided by the host app.
    case customXib
    /**
     Returns a string of the nib
     */
    var nibName: String {
        switch self {
        case .tableViewRegular: return "NativeAdTableViewCell"
            //      case .tableViewBig: return "NativeAdTableViewBigCell"
        case .collectionViewRegular: return "NativeAdCollectionViewCell"
        case .customXib: return "CustomAdCell"
        }
    }
}
