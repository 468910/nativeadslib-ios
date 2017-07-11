//
//  CollectionAdCell.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 20/06/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit

public class CollectionItemCell: UICollectionViewCell {
    @IBOutlet weak var appIcon: UIImageView!

    public func setData(item: ItemTableModel) {
        appIcon.nativeSetImageFromURL(item.imageURL)
    }
}
