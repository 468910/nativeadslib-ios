//
//  AdCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 08/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

open class AdCell: UITableViewCell {

	@IBOutlet open weak var campaignNameLabel: UILabel!
	@IBOutlet open weak var campaignImageView: UIImageView!
	@IBOutlet open var campaignDescriptionLabel: UILabel!

	override open func awakeFromNib() {
		super.awakeFromNib()
	}

}
