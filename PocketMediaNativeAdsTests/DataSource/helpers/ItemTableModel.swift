//
//  ItemTableModel.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation

public class ItemTableModel {
    public var title: String!
    public var descriptionItem: String!
    public var imageURL: NSURL!

    public init?(dictionary: NSDictionary) {
        if let name = dictionary["name"] as? String {
            self.title = name
        } else {
            return nil
        }
        if let description = dictionary["description"] as? String {
            self.descriptionItem = description
        }
        if let urlImage = dictionary["artworkUrl"] as? String, url = NSURL(string: urlImage) {
            self.imageURL = url
        }
    }
}
