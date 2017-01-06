//
//  ItemTableModel.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation

open class ItemTableModel {
    open var title: String!
    open var descriptionItem: String!
    open var imageURL: URL!

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
