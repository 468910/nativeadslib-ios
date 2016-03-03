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
public class BigNativeAdTableViewCell : AbstractAdUnitTableViewCell {
 
  
  /**
  //Objective C initWithStyle
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    print("Using style: reuseIdentifier:")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    print(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
  }*/
  
  
  
  
  
  required public init?(coder aDecoder: NSCoder){
    print("Using coder:")
    super.init(coder: aDecoder)
    //self.translatesAutoresizingMaskIntoConstraints = false
  }
 
}