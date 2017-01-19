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
open class NativeAdTableViewCellRegular: UITableViewCell, NativeViewCell {

    @IBOutlet weak var speakerPhone: UIImageView?
    @IBOutlet weak var adImage: UIImageView?
    @IBOutlet weak var adTitle: UILabel?
    @IBOutlet weak var adDescription: UILabel?
    @IBOutlet weak var installButton: UIButton?

    /// The ad shown in this cell.
    fileprivate(set) open var ad: NativeAd?

    /**
     Called to define what ad should be shown.
     */
    open func render(_ nativeAd: NativeAd, completion handler: @escaping ((Bool) -> Swift.Void)) {
        self.ad = nativeAd

        if let button = installButton {
            setupInstallButton(button)
        }

        if let image = adImage {
            setupAdImage(image)
        }

        if let ad_description = adDescription {
            ad_description.text = ad!.campaignDescription
        }

        if let title = adTitle {
            title.text = ad!.campaignName
        }

        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    internal func setupAdImage(_ image: UIImageView) {
        image.nativeSetImageFromURL(ad!.campaignImage)
        image.layer.cornerRadius = image.frame.width / 10
        image.layer.masksToBounds = true
    }
    
    internal func setupInstallButton(_ button: UIButton) {
        button.layer.borderColor = self.tintColor.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.minimumScaleFactor = 0.1
        let color = UIColor(
            red: 17.0 / 255.0,
            green: 147.0 / 255.0,
            blue: 67.0 / 255.0,
            alpha: 1)
        button.setTitleColor(color, for: UIControlState())
        button.layer.borderColor = color.cgColor
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        button.titleLabel?.minimumScaleFactor = 0.50
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if let image = adImage {
            button.layer.cornerRadius = image.frame.width / 20
        }
        button.setTitle(ad!.callToActionText, for: .normal)
    }

    /**
     Called when the user presses on the call to action button
     */
    @IBAction func install(_ sender: AnyObject) {
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
            self.ad?.openAdUrl(FullscreenBrowser(parentViewController: viewController))
        }
    }
}
