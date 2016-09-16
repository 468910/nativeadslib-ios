//
//  AbstractBigAdUnitTableViewCell.swift
//  Pods
//
//  Created by kees on 18/07/16.
//
//

import UIKit
import Haneke
import Darwin

public class AbstractBigAdUnitTableViewCell: UITableViewCell, NativeAdViewBinderProtocol {

	@IBOutlet weak var adImageHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var adImage: UIImageView?
	@IBOutlet var adIconImage: UIImageView?
	@IBOutlet var firstRowView: UIView?
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

    // Called after has loaded the NiB
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        adDescription?.lineBreakMode = .ByTruncatingTail
        adTitle?.lineBreakMode = .ByTruncatingTail
    }

	override public func prepareForReuse() {
		super.prepareForReuse()
		aspectConstraint = nil
	}

	func setAdImageAndScale(image: UIImage) {
        let aspect = image.size.width / image.size.height
		let screenWidth = UIScreen.mainScreen().bounds.size.width
		let viewWidth = (self.adImage?.bounds.size.width)!
		let imgWidth = viewWidth > screenWidth ? screenWidth : viewWidth
		let newHeight = imgWidth / aspect
		self.adImageHeightConstraint.constant = newHeight
		self.adImage?.image = image
		self.invalidateIntrinsicContentSize()
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}

	public override func intrinsicContentSize() -> CGSize {
		return CGSize.init(width: UIScreen.mainScreen().bounds.size.width, height: requiredHeight())
	}

    private func setAdImage(nativeAd: NativeAd) {
        if (adImage?.frame.height == 0 || adImage?.frame.width == 0) {
            Logger.debug("No image frame for adImage, not setting it.")
            return
        }

        //TODO: Right now it seems that the api is not sending banners, or hq_icon
//        let errorHandler = { (error:NSError) -> Void in
//            Logger.debug("Error downloading the image")
//        }
//        if let imageUrl = nativeAd.images?["banner"] {
//            adImage?.hnk_setImageFromURL(NSURL(string: imageUrl["url"] as! String)?, format: Format(name: "original"), placeholder: nil, success: self.setAdImageAndScale, failure: errorHandler)
//        } else if let imageUrl = nativeAd.images!["hq_icon"] {
//            adImage?.hnk_setImageFromURL(NSURL(string: imageUrl!["url"] as? String)?, format: Format(name: "original"), placeholder: nil, success: self.setAdImageAndScale, failure: errorHandler)
//        }

        adIconImage?.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
    }

	public func configureAdView(nativeAd: NativeAd) {
		adTitle?.text = nativeAd.campaignName
		adDescription?.text = nativeAd.campaignDescription
		adImage?.translatesAutoresizingMaskIntoConstraints = false
		setAdImage(nativeAd)

		if (adIconImage?.frame.height != 0 && adIconImage?.frame.width != 0) {
			adIconImage?.hnk_setImageFromURL(nativeAd.campaignImage, placeholder: UIImage(), format: nil, failure: nil, success: nil)
		} else {
			Logger.debug("No image frame for adIconImage, not setting it.")
		}
	}

	func requiredHeight() -> CGFloat {
		var height: CGFloat = 10.0
		height = height + (self.firstRowView?.bounds.height)! + (self.adImage?.frame.height)!
		return height
    }
}
