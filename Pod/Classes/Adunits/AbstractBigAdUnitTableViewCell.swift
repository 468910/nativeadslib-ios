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

		if let imageUrl = nativeAd.images!["banner"] {
			adImage.hnk_setImageFromURL(NSURL(string: imageUrl["url"] as! String)!, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		} else {
			let imageUrl = nativeAd.images!["hq_icon"]
			adImage.hnk_setImageFromURL(NSURL(string: imageUrl!["url"] as! String)!, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		}
		// adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		adIconImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(),
			format: nil, failure: nil, success: nil)
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

		print("I'M invoked")
	}

}