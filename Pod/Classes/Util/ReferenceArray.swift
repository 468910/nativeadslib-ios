//
//  ReferenceArray.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 02/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
// Note This is Added because Arrays are copied by value. But why!?

import UIKit
@objc
public class ReferenceArray : NSObject  {
  // [T] is syntatic sugar for Array<T>
  @objc
  public var collection : [AnyObject] = []
  
  public var count : AnyObject {
    return collection.count
  }
  public func append(object: AnyObject){
    collection.append(object)
  }
  
}

public class AdViewLoader : NSObject {
  
  /**
   Loads Nib for UIView 
    usage: Uses Type T as name for file
   - Returns: UIView class requested as Type T
  */
  public static func loadUIViewFromNib<T>() -> T {
    return NSBundle.mainBundle().loadNibNamed(String(T), owner: self, options: nil).first as! T
  }
}

@objc
/**
  - Acessing the internal PocketMediaNativeAds Framework Bundle 
**/
public class PocketMediaNativeAdsBundle : NSObject {
  
  public static func loadBundle() -> NSBundle?{
   let podBundle = NSBundle(forClass: NativeAd.self)
    if let bundleURL = podBundle.URLForResource("Adrian", withExtension: "bundle"){
       print("Bundle found")
      if let bundle = NSBundle(URL: bundleURL){
        print("Bundle returned")
            return bundle
          }
      }
      return nil
    }
  }
