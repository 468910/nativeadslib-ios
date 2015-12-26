//
//  ItemCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

class ItemCell : UITableViewCell {
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var descriptionItem: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
}