//
//  ItemTableModel.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import UIKit

public class ItemTableModel {

    public var title: String!
    public var descriptionItem: String!
    public var imageURL: URL!

    public init?(dictionary: Dictionary<String, Any>) {
        if let name = dictionary["name"] as? String {
            self.title = name
        } else {
            return nil
        }
        if let description = dictionary["description"] as? String {
            self.descriptionItem = description
        }
        if let urlImage = dictionary["artworkUrl"] as? String, let url = URL(string: urlImage) {
            self.imageURL = url
        }
    }
}
