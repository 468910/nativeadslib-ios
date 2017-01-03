//
//  EImageType.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 03/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 Types of images for the ads we want to receive. If an ad doesn't have the required image type it won't be returned.
 */
public enum EImageType: String {
    /// All images.
    case allImages = ""
    /// only images in icon format will be returned.
    case icon = "icon"
    /// only images in icon high quality will be returned.
    case hqIcon = "hq_icon"
    /// only banner images will be returned.
    case banner = "banner"
    /// both banner and high quality icons will be returned.
    case bigImages = "banner,hq_icon"
    /// both banner and icons will be returned.
    case bannerAndIcons = "banner,icon"
}
