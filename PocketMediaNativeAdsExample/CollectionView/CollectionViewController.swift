//
//  CollectionViewController.swift
//  PocketMediaNativeAds
//
//  Created by Pocket Media on 20/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

/**
 Example of the AdStream with an CollectionView
 **/
class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!

	override func viewDidLoad() {

//		self.title = "CollectionView"
//		loadLocalJSON()
//		collectionView?.delegate = self
//		collectionView?.dataSource = self
//
//		self.collectionView.backgroundColor = UIColor.whiteColor()
//		collectionView.collectionViewLayout = NativeAdCollectionViewLayout()
//
//		let adPos = [5, 2, 4]
//		let stream = NativeAdStream(controller: self, mainView: self.collectionView, adsPositions: adPos)
//		stream.requestAds("d5737f99307e376c635bcbd13b308decda8e46b8", limit: 10)

	}

	// --Delegate--

	// --DataSource--

	var collection: [AnyObject] = []

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collection.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCell", for: indexPath) as! CollectionAdCell
		return cell
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

}
