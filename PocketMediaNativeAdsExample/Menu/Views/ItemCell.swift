//
//  ItemCell.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit

public class ItemCell: UITableViewCell {

    @IBOutlet public weak var name: UILabel!
    @IBOutlet public weak var artworkImageView: UIImageView!
    @IBOutlet public weak var descriptionItem: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
