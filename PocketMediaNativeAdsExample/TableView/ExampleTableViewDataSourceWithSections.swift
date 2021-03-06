//
//  ExampleTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 19/04/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

public class ExampleTableViewDataSourceWithSections: NSObject, UITableViewDataSource {

    var collection: [AnyObject] = []

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Section 1"
        case 1:
            return "Section 2"
        default:
            return "This is not a valid section?"
        }
    }

    func loadLocalJSON() {
        do {
            let path = Bundle(for: ExampleTableViewDataSourceWithSections.self).path(forResource: "DummyData", ofType: "json")
            let jsonData: Data = try! Data(contentsOf: URL(fileURLWithPath: path!))
            var jsonArray: NSArray = NSArray()
            jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? Dictionary<String, Any>, let item = ItemTableModel(dictionary: itemDictionary) {
                    collection.append(item)
                }
            }

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = collection[indexPath.row] as? ItemTableModel {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell {
                cell.name.text = item.title
                cell.descriptionItem.text = item.descriptionItem
                cell.artworkImageView.nativeSetImageFromURL(item.imageURL)
                return cell
            }
        }
        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, heightForHeaderIn section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
}
