//
//  NativeAdTableView.swift
//  Pods
//
//  Created by apple on 12/08/16.
//
//

import UIKit

public class NativeAdTableView : UITableView {
  
  private weak var adStream : NativeAdStream?
  
  override public var indexPathForSelectedRow : NSIndexPath? {
    get {
      if let index  = super.indexPathForSelectedRow {
      if let val = adStream!.isAdAtposition(index.row){
        return super.indexPathForSelectedRow
      }else {
       return NSIndexPath(forRow: adStream!.normalize(index.row), inSection: 0)
      }
      }
      return NSIndexPath()
    }
  }
  
  required public init(tableView : UITableView, adStream : NativeAdStream) {
    super.init(frame: tableView.frame, style: tableView.style)
    self.delegate = tableView.delegate
    self.dataSource = tableView.dataSource
    self.adStream = adStream
    
    if let nibMap = tableView.valueForKey("_nibMap") {
      self.setValue(nibMap, forKey: "_nibMap")
    }
    
    if let nibExternalObjectsMap = tableView.valueForKey("_nibExternalObjectsTables") {
      self.setValue(nibExternalObjectsMap, forKey: "nibExternalObjectsTables")
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func attachAdStream(adStream : NativeAdStream){
    self.adStream = adStream
  }
}
