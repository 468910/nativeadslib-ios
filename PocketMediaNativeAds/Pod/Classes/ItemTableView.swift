//
//  ItemTableView.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import Foundation

struct ItemTableView {
  
  var title           : String!
  var descriptionItem : String!
  var imageURL        : NSURL!
  
  init?(dictionary: NSDictionary){
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