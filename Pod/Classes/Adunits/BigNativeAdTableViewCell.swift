//
//  BigNativeAdTableViewCell.swift
//  Pods
//
//  Created by apple on 23/02/16.
//
//

import UIKit

/**
*/
@objc
public class BigNativeAdTableViewCell : AbstractAdUnitTableViewCell {
 

  
  required public init?(coder aDecoder: NSCoder){
    print("Using coder:")
    super.init(coder: aDecoder)
  }
 
}