//
//  TableViewController.swift
//  NativeAdsSwift
//
//  Created by Kees Bank on 01/06/15.
//  Copyright (c) 2015 Pocket Media. All rights reserved.
//

import UIKit
import PocketMediaNativeAds

class TableViewController: UITableViewController {
  
    var tableViewDataSource : ExampleTableViewDataSource?
  
    override func viewDidLoad() {
      
      super.viewDidLoad()
      tableViewDataSource = ExampleTableViewDataSource()
      tableViewDataSource!.loadLocalJSON()
      tableView.dataSource = tableViewDataSource
      
      
    var xib = UINib(nibName: "TestSupplied", bundle: nil)
      
      
      var adPos = [5, 2, 4, 99]
    //var stream = NativeAdStream(controller: self, mainView: self.tableView, adsPositions: adPos)
      var stream = NativeAdStream(controller: self, mainView: self.tableView, adFrequency: 1, firstAdPosition: 1)
     stream.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
    }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80
  }
 
 
  
  
  
    
}

extension UIImageView {
  public func imageFromServerURL(urlString: String) {
    
    NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
      
      if error != nil {
        print(error)
        return
      }
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let image = UIImage(data: data!)
        self.image = image
      })
      
    }).resume()
  }}
