//
//  ItemCell.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
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
}
