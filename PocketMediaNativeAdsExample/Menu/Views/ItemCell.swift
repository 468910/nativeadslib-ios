//
//  ItemCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

open class ItemCell: UITableViewCell {
  
  @IBOutlet open weak var name: UILabel!
  @IBOutlet open weak var artworkImageView: UIImageView!
  @IBOutlet open weak var descriptionItem: UILabel!
  
  override open func awakeFromNib() {
    super.awakeFromNib()
  }
  
}
