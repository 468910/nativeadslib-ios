//
//  ExampleTableViewDataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation
import UIKit
import PocketMediaNativeAds

public class ExampleTableViewDataSource: NSObject, UITableViewDataSource {

    var collection: [AnyObject] = []

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.collection.count
        return self.collection.count
    }

    func loadLocalJSON() {
        do {
            let path = NSBundle(forClass: NativeAdsRequestTest.self).pathForResource("DummyData", ofType: "json")
            let jsonData: NSData = NSData(contentsOfFile: path!)!
            var jsonArray: NSArray = NSArray()
            jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray

            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? NSDictionary, item = ItemTableModel(dictionary: itemDictionary) {
                    collection.append(item)
                }
            }

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch collection[indexPath.row] {
        case let item as ItemTableModel:
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
            cell.name.text = item.title
            cell.descriptionItem.text = item.descriptionItem
            cell.artworkImageView.nativeSetImageFromURL(item.imageURL)
            return cell

        default:
            return UITableViewCell()
        }
    }
}
