//
//  CollectionViewController.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 09/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import UIKit
import PocketMediaNativeAds

/**
 Example of the AdStream with an CollectionView
 **/
class CollectionViewController: UICollectionViewController {
    var collection: [ItemTableModel] = []
    var stream: NativeAdStream?

    override func viewDidLoad() {
        loadLocalJSON()

        stream = NativeAdStream(controller: self, view: self.collectionView!, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", customXib: nil, adPosition: PredefinedAdPosition(positions: [2, 3, 8, 9])) /* replace with your own token!! */
        stream?.requestAds(4)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.count
    }

    override func collectionView(_ cellForItemAtcollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let item = collection[indexPath.row] as? ItemTableModel {
            if let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? CollectionItemCell {
                cell.setData(item: item)
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func loadLocalJSON() {

        do {
            let path = Bundle.main.path(forResource: "DummyData", ofType: "json")

            let jsonData: NSData = try NSData(contentsOfFile: path!)
            var jsonArray: NSArray = NSArray()
            jsonArray = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? Dictionary<String, Any>, let item = ItemTableModel(dictionary: itemDictionary) {
                    collection.append(item)
                }
            }

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
