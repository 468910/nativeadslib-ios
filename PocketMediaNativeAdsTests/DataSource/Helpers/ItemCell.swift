//
//  ItemCell.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation
import UIKit

open class ItemCell: UITableViewCell {

    @IBOutlet open weak var name: UILabel!
    @IBOutlet open weak var artworkImageView: UIImageView!
    @IBOutlet open weak var descriptionItem: UILabel!

    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}
