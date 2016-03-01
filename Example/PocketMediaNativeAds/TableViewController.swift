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

class TableViewController: UITableViewController, DisplayHelperDelegate {
  
  func onUpdateCollection() {
    tableView.reloadData()
  }
  
    var injector : NativeAdInjector?
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
      injector = NativeAdInjector(displayHelper: self, datasource: self)
      tableView.dataSource = injector
        super.viewDidLoad()
        loadLocalJSON()
        loadNativeAds()
      
      tableView.registerNib(UINib(nibName: "BigNativeAdTableViewCell", bundle: nil), forCellReuseIdentifier: "BigNativeAdTableViewCell")
      
      tableView.registerNib(UINib(nibName: "NativeAdCell", bundle: nil), forCellReuseIdentifier: "NativeAdCell")
    }
    
    
    func loadNativeAds(){
        injector!.requestAds(NativeAdsRequest(affiliateId: "1234-sample", delegate: injector), limit: 5)
      
    }
    
    func loadLocalJSON(){
        
        
        do{
            let path = NSBundle.mainBundle().pathForResource("DummyData", ofType: "json")
            let jsonData : NSData =  NSData(contentsOfFile: path!)!
            var jsonArray : NSArray = NSArray()
            jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? NSDictionary, item = ItemTableView(dictionary: itemDictionary) {
                    injector!.collection.append(item)
                }
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
 
  
  
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return injector!.collection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("TableView invoked")
            /*
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
            cell.name.text = item.title
            cell.descriptionItem.text = item.descriptionItem
            loadImageAsynchronouslyFromUrl(item.imageURL, imageView: cell.artworkImageView)
            return cell*/
          return UITableViewCell()
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ad = injector!.collection[indexPath.row] as? NativeAd{
            print("Opening url: \(ad.clickURL.absoluteString)")
            // This method will take of opening the ad inside of the app, until we have an iTunes url
            ad.openAdUrl(self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      print("Table view heightForRowInvoked")
      return 80.0;
    }
    
}

