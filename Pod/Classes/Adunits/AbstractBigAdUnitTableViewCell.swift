//
//  AbstractBigAdUnitTableViewCell.swift
//  Pods
//
//  Created by apple on 18/07/16.
//
//

import UIKit
import Haneke
import Darwin

public class AbstractBigAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {

	@IBOutlet weak var adImage: UIImageView!
	@IBOutlet var adIconImage: UIImageView!
	@IBOutlet weak var adTitle: UILabel!
	@IBOutlet weak var adDescription: UILabel!

	public func configureAdView(nativeAd: NativeAd) {
		adTitle.text = nativeAd.campaignName
		adDescription.text = nativeAd.campaignDescription
		print(nativeAd.campaignImage)

		if (adImage.frame.height != 0 && adImage.frame.width != 0) {

			if let imageUrl = nativeAd.images!["banner"] {
				try adImage.hnk_setImageFromURL(NSURL(string: imageUrl["url"] as! String)!, placeholder: UIImage(), format: nil, failure: nil, success: nil)
			} else {
				let imageUrl = try nativeAd.images!["hq_icon"]
				try adImage.hnk_setImageFromURL(NSURL(string: imageUrl!["url"] as! String)!, placeholder: UIImage(), format: nil, failure: nil, success: nil)
			}
		} else {
			NSLog("No image frame for adImage, not setting it.")
		}

		// adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		if (adIconImage.frame.height != 0 && adIconImage.frame.width != 0) {

			adIconImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(),
				format: nil, failure: nil, success: nil)
		} else {
			NSLog("No image frame for adIconImage, not setting it.")
		}
	}

	func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
		abort()
	}

	// After has been loaded from Nib
	public override func awakeFromNib() {
		super.awakeFromNib()
		adDescription.numberOfLines = 0
		adDescription.lineBreakMode = .ByTruncatingTail
		adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.80

		adTitle.numberOfLines = 0
		adTitle.lineBreakMode = .ByTruncatingTail
		adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.70

		// Setting AdDescription And Adtitle

		self.adDescription.backgroundColor = UIColor.redColor()
		self.adTitle.backgroundColor = UIColor.yellowColor()

	}

	// Used to change subviews
	public override func layoutSubviews() {

	}

}