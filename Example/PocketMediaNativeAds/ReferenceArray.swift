//
//  ReferenceArray.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
// Note This is Added because Arrays are copied by value. But why!?

import UIKit
import PocketMediaNativeAds

public class ReferenceArray<T> {
  
  public var collection : [T] = []
}

public class AdViewLoader : NSObject {
  
  /**
   Loads Nib for UIView 
    usage: Uses Type T as name for file
   - Returns: UIView class requested as Type T
  */
  public static func loadUIViewFromNib<T>(nativead: NativeAd) -> T {
    return NSBundle.mainBundle().loadNibNamed(String(T), owner: self, options: nil).first as! T
  }
}