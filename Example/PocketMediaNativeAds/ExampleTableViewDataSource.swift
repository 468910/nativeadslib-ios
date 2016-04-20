//
//  ExampleTableViewDelegate.swift
//  PocketMediaNativeAds
//
//  Created by apple on 19/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class ExampleTableViewDataSource : NSObject,  UITableViewDataSource {
  
  var collection : [AnyObject] = []
  
  
  
  
  
  
  
  // MARK: - Table view data source
  
  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.collection.count
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
  
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
   switch collection[indexPath.row] {
    case let item as ItemTableModel :
      print("ItemTablemodel")
      let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
      cell.name.text = item.title
      cell.descriptionItem.text = item.descriptionItem
      //loadImageAsynchronouslyFromUrl(item.imageURL, imageView: cell.artworkImageView)
      return cell
      
    default:
      print("Normal")
      return UITableViewCell()
    }
    
  }
  
  
  
   public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //
  }
  
   public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    print("Table view heightForRowInvoked")
    return 80.0;
  }
  
}