//
//  NativeAdsError.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import Foundation

/**
 Error types that are thrown when building an ad.
 
 - InvalidAdNoCampaign: Thrown when the ad doesn't have name: campaign_name.
 - InvalidAdNoClickUrl: Thrown when the ad doesn't have a click URL: click_url.
 - InvalidAdNoCampaignDescription: Thrown when the ad doesn't have a description: campaign_description.
 - InvalidAdNoId: Thrown when the ad doesn't have a id: id
 - InvalidAdNoImage: Thrown when the ad doesn't have a image: either default_icon or campaign_image
 - InvalidAdNoImages: Thrown when the ad doesn't have images.
 */
enum NativeAdsError: Error {
	case invalidAdNoCampaign
	case invalidAdNoClickUrl
	case invalidAdNoCampaignDescription
	case invalidAdNoId
	case invalidAdNoImage
	case invalidAdNoImages
}
