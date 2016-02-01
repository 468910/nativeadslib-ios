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

class TableViewController: UITableViewController, NativeAdsConnectionProtocol {
    
    var itemsTable: [Any] = []
    var nativeAds: [NativeAd] = []
    
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalJSON()
        loadNativeAds()
    }
    
    
    func loadNativeAds(){
        
        let adRequest = NativeAdsRequest(affiliateId: "1234-sample", delegate: self, parentView: self.view, followRedirectsInBackground: true)
        adRequest.debugModeEnabled = true
        adRequest.retrieveAds(5)
    }
    
    func loadLocalJSON(){
        
        
        do{
            let path = NSBundle.mainBundle().pathForResource(NativeAdsConstants.DummyFile, ofType: "json")
            let jsonData : NSData =  NSData(contentsOfFile: path!)!
            var jsonArray : NSArray = NSArray()
            jsonArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            for itemJson in jsonArray {
                if let itemDictionary = itemJson as? NSDictionary, item = ItemTableView(dictionary: itemDictionary) {
                    itemsTable.append(item)
                }
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func loadImageAsynchronouslyFromUrl(url: NSURL, imageView: UIImageView){
        imageView.af_setImageWithURL(url)
    }
    
    // MARK : - Native Ads Protocol
    
    func didRecieveError(error: NSError){
        print(error.description)
    }
    
    func didRecieveResults(nativeAds: [NativeAd]){
        self.nativeAds = nativeAds
        if itemsTable.count > 0 {
            for ad in nativeAds {
                itemsTable.insert(ad, atIndex: Int(arc4random_uniform(UInt32(itemsTable.count))))
            }
            tableView.reloadData()
        }
    }
    
    func didUpdateNativeAd(updatedAd : NativeAd){
        NSLog("Updated ad: %@. New url: %@", updatedAd.originalClickUrl, updatedAd.clickURL)
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
            
            if(ad.campaignImage != nil){
            loadImageAsynchronouslyFromUrl(ad.campaignImage, imageView: cell.campaignImageView)
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ad = itemsTable[indexPath.row] as? NativeAd{
            print("Opening url: \(ad.clickURL.absoluteString)")
            // This method will take of opening the ad inside of the app, until we have an iTunes url
            ad.openCampaign(parentViewController : self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
}

