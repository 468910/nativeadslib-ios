//
//  ViewController.swift
//  PocketMediaNativeAds
//
//  Created by Adrián Moreno Peña on 01/02/2016.
//  Copyright (c) 2016 Adrián Moreno Peña. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class ViewController: UITableViewController, NativeAdConnectionProtocol {

    var itemsTable: [Any] = []
    var nativeAds: [NativeAd] = []
    
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalJSON()
        let adRequest = NativeAdsRequest()
        adRequest.retrieveAds(1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadLocalJSON(){
        if let path = NSBundle.mainBundle().pathForResource(NativeAdsConstants.DummyFile, ofType: "json"), jsonData = NSData(contentsOfFile: path), json: NSArray = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
            for itemJson in json {
                if let itemDictionary = itemJson as? NSDictionary, item = ItemTableView(dictionary: itemDictionary) {
                    itemsTable.append(item)
                }
            }
        }
    }
    
    func loadImageAsynchronouslyFromUrl(url: NSURL, imageView: UIImageView){
        if let img = imageCache[url.path!] {
            imageView.image = img
        } else {
            let request: NSURLRequest = NSURLRequest(URL: url)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if let data = data {
                    let image = UIImage(data: data)
                    self.imageCache[url.path!] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        imageView.image = image
                    })
                }
                else if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            })
        }
    }
    
    // MARK : - Native Ads Protocol
    
    func didRecieveError(error: NSError){
        print(error.description)
    }
    
    func didRecieveResults(nativeAds: [NativeAd]){
        self.nativeAds = nativeAds
        if itemsTable.count > 0 {
            for ad in nativeAds {
                itemsTable.insert(ad, atIndex: Int(arc4random_uniform(4))+1)
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsTable.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch itemsTable[indexPath.row] {
        case let item as ItemTableView :
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
            cell.name.text = item.title
            cell.descriptionItem.text = item.descriptionItem
            loadImageAsynchronouslyFromUrl(item.imageURL, imageView: cell.artworkImageView)
            return cell
        case let ad as NativeAd :
            let cell = tableView.dequeueReusableCellWithIdentifier("AdCell", forIndexPath:indexPath) as! AdCell
            cell.campaignNameLabel.text = ad.campaignName
            cell.campaignDescriptionLabel.text = ad.campaignDescription
            loadImageAsynchronouslyFromUrl(ad.campaignImage, imageView: cell.campaignImageView)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ad = itemsTable[indexPath.row] as? NativeAd{
            UIApplication.sharedApplication().openURL(ad.clickURL)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
}

