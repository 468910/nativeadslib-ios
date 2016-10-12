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
    
    private(set) open var ad: NativeAd?

	public func configureAdView(_ nativeAd: NativeAd) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.ad = nativeAd
		if let title = adTitle {
			title.text = nativeAd.campaignName
		}
		if let description = adDescription {
			description.text = nativeAd.campaignDescription
		}

		if let image = adImage {
            image.image = UIImage()
            image.nativeSetImageFromURL(nativeAd.campaignImage)
		}
        
	}

	// After has been loaded from Nib
	public override func awakeFromNib() {
		super.awakeFromNib()

		if let ad_description = adDescription {
			ad_description.numberOfLines = 0
			ad_description.lineBreakMode = .byTruncatingTail
			ad_description.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.80
			ad_description.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.70
		}

        if let image = adImage {
            image.image = UIImage()
        }

		if let title = adTitle {
			title.numberOfLines = 0
			title.lineBreakMode = .byTruncatingTail
		}
	}

}
