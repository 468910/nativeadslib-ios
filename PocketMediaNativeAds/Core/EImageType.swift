//
//  EImageType.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 10/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 Types of images for the ads we want to receive. If an ad doesn't have the required image type it won't be returned.
 */
@objc
public enum EImageType: Int, CustomStringConvertible {

    case allImages = 0 // ""
    case icon = 1 // "icon"
    case hqIcon = 2 // "hq_icon"
    case banner = 3 // "banner"
    case bigImages = 4 // "banner,hq_icon"
    case bannerAndIcons = 5 // "banner,icon"

    init?(string: String) {
        switch string {
        case "allImages": self = .allImages
        case "icon": self = .icon
        case "hq_icon": self = .hqIcon
        case "banner": self = .banner
        case "bigImages": self = .bigImages
        case "bannerAndIcons": self = .bannerAndIcons
        default: self = .allImages
        }
    }

    public var description: String {
        switch self {
        case .allImages: return ""
        case .icon: return "icon"
        case .hqIcon: return "hq_icon"
        case .banner: return "banner"
        case .bigImages: return "banner,hq_icon"
        case .bannerAndIcons: return "banner,icon"
        }
    }
}
