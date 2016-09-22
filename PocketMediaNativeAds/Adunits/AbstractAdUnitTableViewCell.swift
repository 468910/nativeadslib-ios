//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

/**
 Class to be subclassed for use with the AdStream.
 **/
public class AbstractAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {

	@IBOutlet weak var speakerPhone: UIImageView?
	@IBOutlet weak var adImage: UIImageView?
	@IBOutlet weak var adTitle: UILabel?
	@IBOutlet weak var adDescription: UILabel?

	public func configureAdView(nativeAd: NativeAd) {
		if let title = adTitle {
			title.text = nativeAd.campaignName
		}
		if let description = adDescription {
			description.text = nativeAd.campaignDescription
		}

		if let image = adImage {
            image.image = UIImage()
            image.setImageFromURL(nativeAd.campaignImage)
		}
	}

	// After has been loaded from Nib
	public override func awakeFromNib() {
		super.awakeFromNib()

		if let ad_description = adDescription {
			ad_description.numberOfLines = 0
			ad_description.lineBreakMode = .ByTruncatingTail
			ad_description.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.80
			ad_description.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.70
		}

        if let image = adImage {
            image.image = UIImage()
        }

		if let title = adTitle {
			title.numberOfLines = 0
			title.lineBreakMode = .ByTruncatingTail
		}
	}

}
