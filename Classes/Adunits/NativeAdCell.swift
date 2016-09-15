//
//  NativeAdCell.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 29/02/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

/**
 Standard AdUnit for TableView
 **/
public class NativeAdCell: AbstractAdUnitTableViewCell {
    
    @IBOutlet public weak var installButton: UIButton?

	public override func awakeFromNib() {
		super.awakeFromNib()
        if let iButton = installButton {
			iButton.layer.borderColor = self.tintColor.CGColor
			iButton.layer.borderWidth = 1
			iButton.layer.masksToBounds = true
			iButton.titleLabel?.baselineAdjustment = .AlignCenters
			iButton.titleLabel?.textAlignment = .Center
			iButton.titleLabel?.minimumScaleFactor = 0.1
			let color = UIColor(red: 17.0 / 255.0, green: 147.0 / 255.0, blue: 67.0 / 255.0, alpha: 1)
			iButton.setTitleColor(color, forState: .Normal)
			iButton.layer.borderColor = color.CGColor
			iButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
			iButton.titleLabel?.minimumScaleFactor = 0.50
			iButton.titleLabel?.adjustsFontSizeToFitWidth = true
			if let image = adImage {
				iButton.layer.cornerRadius = CGRectGetWidth(image.frame) / 20
				image.layer.cornerRadius = CGRectGetWidth(image.frame) / 10
				image.layer.masksToBounds = true
			}
		}
	}
}