//
//  ExampleTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 19/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class ExampleTableViewDataSource: NSObject, UITableViewDataSource {

	var collection: [AnyObject] = []

	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}

	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.collection.count
	}

	func loadLocalJSON() {
		do {
			let path = NSBundle.mainBundle().pathForResource("DummyData", ofType: "json")
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
//                cell.name.text = String(indexPath.row)
                cell.descriptionItem.text = item.descriptionItem
                cell.artworkImageView.nativeSetImageFromURL(item.imageURL)
                return cell
            default:
                return UITableViewCell()
		}

	}

}
