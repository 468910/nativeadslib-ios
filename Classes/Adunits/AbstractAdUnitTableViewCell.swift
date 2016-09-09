//
//  AbstractAdUnit.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 03/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Haneke
import Darwin


/**
 Class to be subclassed for use with the AdStream.
 **/
public class AbstractAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {

	@IBOutlet weak var speakerPhone: UIImageView?
	@IBOutlet weak var adImage: UIImageView?
	@IBOutlet weak var adTitle: UILabel?
	@IBOutlet weak var adDescription: UILabel?
	@IBOutlet weak var adInfoView: UIView?

	@IBOutlet weak var adDescriptionHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var middleLineCenterYConstraint: NSLayoutConstraint!

	public func configureAdView(nativeAd: NativeAd) {
      if let title = adTitle {
        title.text = nativeAd.campaignName
      }
      
      if let description = adDescription {
        description.text = nativeAd.campaignDescription
      }
      
      if let image = adImage {
		image.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
      }
      
	}

	func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
		abort()
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
     

		// Setting AdDescription And Adtitle

	}

	// Used to change subviews
	public override func layoutSubviews() {

	}

	public override func updateConstraints() {
		super.updateConstraints()

		

	}

}

struct MyConstraint {
	static func changeMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
		let newConstraint = NSLayoutConstraint(
			item: constraint.firstItem,
			attribute: constraint.firstAttribute,
			relatedBy: constraint.relation,
			toItem: constraint.secondItem,
			attribute: constraint.secondAttribute,
			multiplier: multiplier,
			constant: constraint.constant)

		newConstraint.priority = constraint.priority

		NSLayoutConstraint.deactivateConstraints([constraint])
		NSLayoutConstraint.activateConstraints([newConstraint])

		return newConstraint
	}
}

