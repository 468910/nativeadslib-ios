//
//  NativeAdTableView.swift
//  Pods
//
//  Created by apple on 12/08/16.
//
//

import UIKit

public class NativeAdTableView : UITableView {
  
  
  
  override public var indexPathForSelectedRow : NSIndexPath? {
    get{
      
      if let indexPath = super.indexPathForSelectedRow {
       
        var normalized = NativeAdStream.adStreamRegister[self.objectName]!.normalize(indexPath)
       return NSIndexPath(forRow: normalized, inSection: indexPath.section)
      
      }else {
        return nil
      }
     
    }
 
  }
  
 
}



public extension UIView {

  var objectName : String {
     return  String(ObjectIdentifier(self).uintValue)
  }
}