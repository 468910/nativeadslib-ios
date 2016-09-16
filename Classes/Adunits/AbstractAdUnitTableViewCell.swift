//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Darwin

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
            dispatch_async(dispatch_get_main_queue(), {
                image.contentMode = UIViewContentMode.ScaleAspectFit
                image.clipsToBounds = true
                // Cache the image
                if let campaignImage = nativeAd.campaignImage.cachedImage {
                    // Cached: set immediately.
                    image.image = campaignImage
                    image.alpha = 1
                } else {
                    // Not cached, so load then fade it in.
                    image.alpha = 0
                    nativeAd.campaignImage.fetchImage { downloadedImage in
                        // Check the cell hasn't recycled while loading.
                        if nativeAd.campaignImage == downloadedImage {
                            image.image = downloadedImage
                            image.reloadInputViews()
                            UIView.animateWithDuration(0.3) {
                                image.alpha = 1
                                image.setNeedsDisplay()
                            }
                        }
                    }
                }
            })
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

		if let title = adTitle {
			title.numberOfLines = 0
			title.lineBreakMode = .ByTruncatingTail
		}
	}

}
