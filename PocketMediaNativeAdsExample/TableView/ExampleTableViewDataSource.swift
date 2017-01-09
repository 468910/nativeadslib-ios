//
//  ExampleTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 19/04/16.
//  Copyright © 2016 PocketMedia. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

open class ExampleTableViewDataSource: NSObject, UITableViewDataSource {

    var collection: [AnyObject] = []

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection.count
    }

    func loadLocalJSON() {
        do {
            let path = Bundle(for: ExampleTableViewDataSource.self).path(forResource: "DummyData", ofType: "json")
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
                cell.setData(item: item)
                return cell
            }
        }

        return UITableViewCell()
    }
}
