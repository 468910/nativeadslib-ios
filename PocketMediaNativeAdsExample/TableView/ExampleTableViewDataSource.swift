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

	public func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.collection.count
	}

	func loadLocalJSON() {
		do {
			let path = Bundle.main.path(forResource: "DummyData", ofType: "json")
			let jsonData: Data = try! Data(contentsOf: URL(fileURLWithPath: path!))
			var jsonArray: NSArray = NSArray()
			jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
			for itemJson in jsonArray {
				if let itemDictionary = itemJson as? NSDictionary, let item = ItemTableModel(dictionary: itemDictionary) {
					collection.append(item)
				}
			}
		} catch let error as NSError {
			print(error.localizedDescription)
		}
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch collection[(indexPath as NSIndexPath).row] {
            case let item as ItemTableModel:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
                cell.name.text = item.title
                cell.descriptionItem.text = item.descriptionItem
                cell.artworkImageView.nativeSetImageFromURL(item.imageURL)
                return cell
            default:
                return UITableViewCell()
		}

	}

}
