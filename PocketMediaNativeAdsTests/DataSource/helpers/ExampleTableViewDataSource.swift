//
//  ExampleTableViewDataSource.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 13/09/16.
//
//

import Foundation
import UIKit

public class ExampleTableViewDataSource: NSObject, UITableViewDataSource {

	var collection: [AnyObject] = []

	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

		Logger.debug("The Normalized index is: %d🐬", indexPath.row)

		switch collection[indexPath.row] {
		case let item as ItemTableModel:
			let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
			cell.name.text = item.title
			cell.descriptionItem.text = item.descriptionItem
			// cell.artworkImageView.hnk_setImageFromURL(item.imageURL)
			return cell

		default:
			return UITableViewCell()
		}

	}

}
