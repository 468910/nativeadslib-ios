//
//  CollectionViewController.swift
//  PocketMediaNativeAds
//
//  Created by apple on 20/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PocketMediaNativeAds
import Haneke

class CollectionViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  override func viewDidLoad() {
    
    self.title = "CollectionView"
    loadLocalJSON()
    collectionView?.delegate = self
    collectionView?.dataSource = self
    
    self.collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.collectionViewLayout = NativeAdCollectionViewLayout()
   
    var adPos = [5, 2, 4]
    var stream = NativeAdStream(controller: self, mainView: self.collectionView, adsPositions: adPos)
    stream.requestAds("d5737f99307e376c635bcbd13b308decda8e46b8", limit: 10)

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
    cell.appIcon.hnk_setImageFromURL(item.imageURL)
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
      
    
      
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    
  }
  
  }
