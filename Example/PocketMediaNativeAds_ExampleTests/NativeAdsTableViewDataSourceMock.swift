//
//  NativeAdsTableViewDataSourceMock.swift
//  PocketMediaNativeAds
//
//  Created by apple on 02/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import PocketMediaNativeAds


class NativeAdTableViewDataSourceMock : NativeAdTableViewDataSource {
  
  
  @objc required init(datasource: UITableViewDataSource, tableView: UITableView, delegate: UITableViewDelegate, controller: UITableViewController) {
    fatalError("init(datasource:tableView:delegate:controller:) has not been implemented")
  }
  
  @objc required init(controller: UIViewController, tableView: UITableView, adStream: NativeAdStream) {
    fatalError("init(controller:tableView:adStream:) has not been implemented")
  }
  

  
  @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
 
  @objc override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}

class UITableViewDelegateMock : NSObject, UITableViewDelegate {
  
  
  override init(){
    super.init()
  }
  
  @objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return CGFloat(0)
  }
}

