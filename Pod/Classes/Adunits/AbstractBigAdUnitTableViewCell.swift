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

	@IBOutlet weak var adImage: UIImageView?
	@IBOutlet var adIconImage: UIImageView?
	@IBOutlet var firstRowView: UIView?

	// @IBOutlet var aspectConstraint: NSLayoutConstraint?

	@IBOutlet weak var adTitle: UILabel?
	@IBOutlet weak var adDescription: UILabel?

	internal var aspectConstraint: NSLayoutConstraint? {
		didSet {
			if oldValue != nil {
				adImage?.removeConstraint(oldValue!)
			}
			if aspectConstraint != nil {
				adImage?.addConstraint(aspectConstraint!)
			}
		}
	}

	override public func prepareForReuse() {
		super.prepareForReuse()
		aspectConstraint = nil
	}

	func setAdImageAndScale(image: UIImage) {

		var aspect = image.size.width / image.size.height

		NSLog("0. Image width: \(image.size.width), height: \(image.size.height), ratio: \(aspect)")
		NSLog("1. ImageView width: \(adImage?.frame.size.width), height: \(adImage?.frame.size.height), position x: \(adImage?.bounds.origin.x), position y: \(adImage?.bounds.origin.y)")

		aspectConstraint = NSLayoutConstraint(item: adImage!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: adImage!, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
		aspectConstraint?.priority = 1000

		adImage?.image = image

		NSLog("2. ImageView width: \(adImage?.frame.size.width), height: \(adImage?.frame.size.height), position x: \(adImage?.bounds.origin.x), position y: \(adImage?.bounds.origin.y)")

		invalidateIntrinsicContentSize()
		setNeedsLayout()
		layoutIfNeeded()
	}

	public override func intrinsicContentSize() -> CGSize {
		return CGSize.init(width: UIScreen.mainScreen().bounds.size.width, height: requiredHeight())
	}

	func configureAdView(nativeAd: NativeAd, viewController: UIViewController) {
		self.configureAdView(nativeAd)
	}

	public func configureAdView(nativeAd: NativeAd) {
		adTitle?.text = nativeAd.campaignName
		adDescription?.text = nativeAd.campaignDescription

		adImage?.translatesAutoresizingMaskIntoConstraints = false

		if (adImage?.frame.height != 0 && adImage?.frame.width != 0) {

			if let imageUrl = nativeAd.images!["banner"] {
				try adImage?.hnk_setImageFromURL(NSURL(string: imageUrl["url"] as! String)!, format: Format(name: "original"), placeholder: nil, success: { (image) -> Void in

					self.setAdImageAndScale(image)

					}, failure: { (error) -> Void in
					NSLog("Error downloading the image")
					}
				)
			} else {
				let imageUrl = nativeAd.images!["hq_icon"]
				try adImage?.hnk_setImageFromURL(NSURL(string: imageUrl!["url"] as! String)!, format: Format(name: "original"), placeholder: nil, success: { (image) -> Void in

					self.setAdImageAndScale(image)

					}, failure: { (error) -> Void in
					NSLog("Error downloading the image")
					}
				)
			}

			adImage?.backgroundColor = UIColor.redColor()

		} else {
			NSLog("No image frame for adImage, not setting it.")
		}

		// adImage.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		if (adIconImage?.frame.height != 0 && adIconImage?.frame.width != 0) {

			adIconImage?.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(),
				format: nil, failure: nil, success: nil)
		} else {
			NSLog("No image frame for adIconImage, not setting it.")
		}
	}

	func requiredHeight() -> CGFloat {
		var height: CGFloat = 10.0;
		try height = height + (self.firstRowView?.bounds.height)! + (self.adImage?.frame.height)!
		return height
	}

	// After has been loaded from Nib
	public override func awakeFromNib() {
		super.awakeFromNib()
		// adDescription.numberOfLines = 0
		adDescription?.lineBreakMode = .ByTruncatingTail
		// adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.80

		// adTitle.numberOfLines = 0
		adTitle?.lineBreakMode = .ByTruncatingTail
		// adDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width * 0.70

		// Setting AdDescription And Adtitle

	}

	// Used to change subviews
	public override func layoutSubviews() {
		NSLog("AbstractBigAdUnitTableViewCell. LayoutSubviews")
		super.layoutSubviews()
	}

}