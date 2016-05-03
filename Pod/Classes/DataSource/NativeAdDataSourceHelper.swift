//
//  NativeAdDataSourceHelper.swift
//  Pods
//
//  Created by apple on 02/05/16.
//
//

import Darwin

class NativeAdDataSourceHelper {
  
  
  var collectionSize : Int
  
  init(collectionSize : Int){
    self.collectionSize = collectionSize
  }
  
  func normalize(rowNumber : Int, adMargin : Int) -> Int{
    if(adMargin < 2){
      NSLog("AdMargin should be higher than 1")
      return -1
    }
    
    if(rowNumber == 0 || rowNumber < adMargin){
      print("No ad placed")
      return rowNumber
    }
    //NSLog("\(rowNumber) - \(rowNumber) / \(adMargin)")
    if((rowNumber % adMargin) == 0){
      NSLog("this index is an Ad")
      return -1
    }
    
    return (rowNumber - (rowNumber / adMargin))
  }
  
  func isIndexNativeAd(rowNumber : Int, adMargin : Int) -> Bool{
    if(rowNumber == 0 || adMargin == 0){
      return false
    }
    
    if((rowNumber % adMargin) == 0 && (rowNumber > 0)){
      return true
    }else {
      return false
    }
  }
}