//
//  File.swift
//  Pods
//
//  Created by apple on 09/09/16.
//
//

import Foundation


class IndexRowNormalizer {
  
  public static var debugModeEnabled : Bool = false
  
  
  static func getTruePosistionForIndexPath(indexPath: NSIndexPath, datasource: NativeAdTableViewDataSourceProtocol) -> Int{
    if(indexPath.section == 0){
      return indexPath.row
    }
    
    var totalRows = 0
    var section = indexPath.section
    for i in (0...max(indexPath.section - 1, 0)){
      var rowsInSection = datasource.getNumberOfRowsInSection(numberOfRowsInSection: i)
      totalRows += rowsInSection
    }
    
    var truePath = max(totalRows - 1,  0 ) + indexPath.row
    print("The true path is : \(truePath)")
    
    return max(totalRows - 1, 0) + indexPath.row
  }
  
  
  static func normalize(indexRow: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int{
    var adsInserted = 0
    
    if (adsCount == 0 || indexRow == 0 || firstAdPosition > indexRow) {
      
      NSLog("Normalized position = position \(indexRow) (original was \(indexRow))")
      
      return indexRow
      
    } else {
      
      
      var temp = min(((indexRow - firstAdPosition) / adMargin) + 1 , adsCount)
      adsInserted = min(((indexRow - firstAdPosition) / adMargin) + 1 , adsCount)
    }
    
     if (debugModeEnabled) {
     NSLog("Normalized position = position - adsInserted \(indexRow - adsInserted) (original was \(indexRow)")
     }
    
    return indexRow - adsInserted
  }
  
  static func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int, firstAdPosition: Int, adMargin : Int, adsCount : Int) -> Int {
    if(debugModeEnabled){
      print("numOfRowsInSection \(numOfRowsInSection) totalRowsInSection \(totalRowsInSection)")
    }
    
    guard numOfRowsInSection > 0 &&
      totalRowsInSection > firstAdPosition
      && adsCount > 0 else {
        return numOfRowsInSection
    }
    
    var numOfAds = getAdsForRange(numOfRowsInSection - totalRowsInSection...totalRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)
    
    var adsInPreviousSections = getAdsForRange(0...totalRowsInSection - numOfRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)
    
    return  min(numOfAds, adsCount - adsInPreviousSections) + numOfRowsInSection
  }
  
  
  static func getAdsForRange(range : Range<Int>, firstAdPosition: Int, adMargin : Int) -> Int{
    return range.filter {
      ($0 % adMargin == 0) && (!(0...firstAdPosition ~= $0))
      }.count + (range.contains(firstAdPosition) ? 1 : 0)
    
  }
  
}