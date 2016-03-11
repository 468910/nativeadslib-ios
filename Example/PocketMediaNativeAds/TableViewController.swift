//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Carolina Barreiro Cancela on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import AlamofireImage
import PocketMediaNativeAds

class TableViewController: UITableViewController {
  
    var itemsTable: [Any] = []
    var tableViewDataSource : NativeAdTableViewDataSource?
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        tableViewDataSource = NativeAdTableViewDataSource(datasource: self, tableView: self.tableView)
        super.viewDidLoad()
        loadLocalJSON()
        loadNativeAds()
    }
    
    
    func loadNativeAds(){
        tableViewDataSource!.requestAds(NativeAdsRequest(affiliateId: "1234-sample", delegate: tableViewDataSource!.nativeAdInjector!), limit: 5)
      
    }
    
    func loadLocalJSON(){
        
        
        do{
            let path = NSBundle.mainBundle().pathForResource("DummyData", ofType: "json")
            let jsonData : NSData =  NSData(contentsOfFile: path!)!
            var jsonArray : NSArray = NSArray()
            jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            
            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? NSDictionary, item = ItemTableView(dictionary: itemDictionary) {
                    itemsTable.append(item)
                    tableViewDataSource!.collection!.append(item)
                }
            }
            
            //for itemJson in jsonArray {
                //if let itemDictionary = itemJson as? NSDictionary, item = ItemTableView(dictionary: itemDictionary) {
                //    tableViewDataSource!.collection!.append(item)
                //}
            //}
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
 
  
  
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewDataSource!.collection!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch itemsTable[indexPath.row] {
        case let item as ItemTableView :

            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
            cell.name.text = item.title
            cell.descriptionItem.text = item.descriptionItem
            loadImageAsynchronouslyFromUrl(item.imageURL, imageView: cell.artworkImageView)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func loadImageAsynchronouslyFromUrl(url: NSURL, imageView: UIImageView){
        imageView.af_setImageWithURL(url)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      print("Table view heightForRowInvoked")
      return 80.0;
    }
    
}

