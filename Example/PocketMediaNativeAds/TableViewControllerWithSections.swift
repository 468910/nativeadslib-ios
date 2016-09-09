//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Kees Bank on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

/**
 Example of the AdStream used with an TableView
 **/
class TableViewControllerWithSections: UITableViewController {
  
  public enum TableSections : Int {
    case FIRST_SECTION = 0
    case SECOND_SECTION = 1
    
  }
  
  
  var tableViewDataSource : ExampleTableViewDataSource?
  var stream : NativeAdStream?
  
  override func viewDidLoad() {
    self.title = "TableView"
    
    super.viewDidLoad()
 
    self.loadLocalJSON()
    tableView.dataSource = self
    
    
    _ = UINib(nibName: "TestSupplied", bundle: nil)
    
    self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    _ = [5, 2, 4, 99]
    
    stream = NativeAdStream(controller: self, mainView: self.tableView, adMargin: 3, firstAdPosition: 1)
    stream!.debugModeEnabled = true
    stream?.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
    
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.indexPathForSelectedRow
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80
  }
  
  
  
  
  func handleRefresh(refreshControl: UIRefreshControl) {
    stream?.clearAdStream("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
    refreshControl.endRefreshing()
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch TableSections(rawValue : section)!{
    case TableSections.FIRST_SECTION:
      return collection.count
    case TableSections.SECOND_SECTION:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch TableSections(rawValue : section)!{
    case TableSections.FIRST_SECTION:
      return "Section 1"
    case TableSections.SECOND_SECTION:
      return "Section 2"
    }
  }
  
  var collection : [AnyObject] = []
  
  
 
  
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
  
  public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    
    var total = collection.count
    
    switch collection[indexPath.row] {
      
    case let item as ItemTableModel :
      print("ItemTablemodel")
      let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
      cell.name.text = item.title
      cell.descriptionItem.text = item.descriptionItem
      cell.artworkImageView.hnk_setImageFromURL(item.imageURL)
      return cell
      
    default:
      print("Normal")
      return UITableViewCell()
    }
    
  }
  
  
  
  
}