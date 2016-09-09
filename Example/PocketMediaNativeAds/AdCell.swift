//
//  AdCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 08/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

public class AdCell : UITableViewCell {
  
  @IBOutlet public weak var campaignNameLabel: UILabel!
  @IBOutlet public weak var campaignImageView: UIImageView!
  @IBOutlet public var campaignDescriptionLabel: UILabel!
  
  override public func awakeFromNib() {
    super.awakeFromNib()
  }
  
}
