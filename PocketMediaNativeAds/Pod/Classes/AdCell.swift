//
//  AdCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 08/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

class AdCell : UITableViewCell {
  
  @IBOutlet weak var campaignNameLabel: UILabel!
  @IBOutlet weak var campaignImageView: UIImageView!
  @IBOutlet var campaignDescriptionLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
}
