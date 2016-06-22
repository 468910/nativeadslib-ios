//
//  CollectionViewController.swift
//  PocketMediaNativeAds
//
//  Created by apple on 20/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class CollectionViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  override func viewDidLoad() {
    
    loadLocalJSON()
    collectionView?.delegate = self
    collectionView?.dataSource = self
   
    var adPos = [5, 2, 4, 99]
    var stream = NativeAdStream(controller: self, mainView: self.collectionView, adsPositions: adPos)
    stream.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)

  }
  
  
  // --Delegate--
  
  
  
  
  // --DataSource--
  
  var collection : [AnyObject] = []
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collection.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell = collectionView.dequeueReusableCellWithReuseIdentifier("TestCell", forIndexPath: indexPath) as! CollectionAdCell
    var item = collection[indexPath.row] as! ItemTableModel
    cell.appTitle.text = item.title
    cell.appIcon.imageFromServerURL(item.imageURL.absoluteString)
    cell.backgroundColor = UIColor.redColor()
    return cell
  }
  
  func loadLocalJSON(){
    
    
    do{
      let path = NSBundle.mainBundle().pathForResource("DummyData", ofType: "json")
      let jsonData : NSData =  NSData(contentsOfFile: path!)!
      var jsonArray : NSArray = NSArray()
      jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
      
      
      for itemJson in jsonArray {
        if let itemDictionary = itemJson as? NSDictionary, item = ItemTableModel(dictionary: itemDictionary) {
          collection.append(item)
        }
      }
      
      //for itemJson in jsonArray {
      //if let itemDictionary = itemJson as? NSDictionary, item = ItemTableModel(dictionary: itemDictionary) {
      //    tableViewDataSource!.collection!.append(item)
      //}
      //}
      
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    
  }
  
  }
