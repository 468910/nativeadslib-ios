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
  private weak var tableView : UITableView?
  
  override public var indexPathForSelectedRow : NSIndexPath? {
    get{
      
      if let indexPath = tableView!.indexPathForSelectedRow {
       var prerow = indexPath.row
       var normalized = adStream!.normalize(prerow)
       return NSIndexPath(forRow: normalized, inSection: indexPath.section)
      
      }else {
        return nil
      }
     
    }
 
  }
  
  
  required public init(tableView : UITableView, adStream : NativeAdStream) {
    super.init(frame: tableView.frame, style: tableView.style)
    self.delegate = tableView.delegate
    self.dataSource = tableView.dataSource
    self.adStream = adStream
    
    self.tableView = tableView
    
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
