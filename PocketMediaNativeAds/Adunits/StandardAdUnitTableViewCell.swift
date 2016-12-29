//
//  NativeAdCell.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 29/02/16.
//  Copyright © 2016 Pocket Media. All rights reserved.
//

import UIKit

/**
 Standard AdUnit for TableView
 **/
open class StandardAdUnitTableViewCell: AbstractAdUnitTableViewCell {

    @IBOutlet weak var speakerPhone: UIImageView?
    @IBOutlet weak var adImage: UIImageView?
    @IBOutlet weak var adTitle: UILabel?
    @IBOutlet weak var adDescription: UILabel?
    @IBOutlet weak var installButton: UIButton?

    open override func render(_ nativeAd: NativeAd) {
        super.render(nativeAd)

        if let iButton = installButton {
            iButton.layer.borderColor = self.tintColor.cgColor
            iButton.layer.borderWidth = 1
            iButton.layer.masksToBounds = true
            iButton.titleLabel?.baselineAdjustment = .alignCenters
            iButton.titleLabel?.textAlignment = .center
            iButton.titleLabel?.minimumScaleFactor = 0.1
            let color = UIColor(
                red: 17.0 / 255.0,
                green: 147.0 / 255.0,
                blue: 67.0 / 255.0,
                alpha: 1)
            iButton.setTitleColor(color, for: UIControlState())
            iButton.layer.borderColor = color.cgColor
            iButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            iButton.titleLabel?.minimumScaleFactor = 0.50
            iButton.titleLabel?.adjustsFontSizeToFitWidth = true

            if let image = adImage {
                iButton.layer.cornerRadius = image.frame.width / 20
            }
            iButton.titleLabel?.text = ad!.callToActionText
        }

        if let image = adImage {
            image.nativeSetImageFromURL(ad!.campaignImage)
            image.layer.cornerRadius = image.frame.width / 10
            image.layer.masksToBounds = true
        }

        if let ad_description = adDescription {
            ad_description.text = ad!.campaignDescription
            ad_description.numberOfLines = 0
            ad_description.lineBreakMode = .byTruncatingTail
            ad_description.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.80
            ad_description.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.70
        }

        if let title = adTitle {
            title.text = ad!.campaignName
            title.numberOfLines = 0
            title.lineBreakMode = .byTruncatingTail
        }

        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    @IBAction func install(_ sender: AnyObject) {
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
            self.ad?.openAdUrl(FullscreenBrowser(parentViewController: viewController))
        }
    }
}
