//
//  ItemCell.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import UIKit

public class ItemCell: UITableViewCell {

    @IBOutlet public weak var name: UILabel!
    @IBOutlet public weak var artworkImageView: UIImageView!
    @IBOutlet public weak var descriptionItem: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setData(item: ItemTableModel) {
        self.name.text = item.title
        self.descriptionItem.text = item.descriptionItem
        self.artworkImageView.nativeSetImageFromURL(item.imageURL)
    }
}
