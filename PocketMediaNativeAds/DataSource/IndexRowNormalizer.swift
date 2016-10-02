//
//  File.swift
//  Pods
//
//  Created by Kees Bank on 09/09/16.
//
//

import Foundation

public class IndexRowNormalizer {
    
    private static var INDEX_OFFSET = 1

    // Calculates the true position for a given index path in the datasource meaning that it checks the position relative to all the sections.
    static internal func getTruePositionForIndexPath(indexPath: NSIndexPath, datasource: NativeAdTableViewDataSourceProtocol) -> Int {
        
        if (indexPath.section == 0) {
            return indexPath.row
        }
    
        // The totalPreviousSectionsRows is the amount of rows that are in the previous sections. When we say previous sections we mean: Sections before the current section of the indexPath.
        var totalPreviousSectionsRows = 0
        for i in (0..<indexPath.section) {
            let rowsInSection = datasource.getNumberOfRowsInSection(numberOfRowsInSection: i)
            totalPreviousSectionsRows += rowsInSection
        }

        let truePath = max(totalPreviousSectionsRows - 1 ,0) + indexPath.row
      
        return truePath
    }

    // Normalizes Index to the Index in the original Datasource
    static internal func normalize(trueIndexCount: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
        
        if(trueIndexCount < firstAdPosition){
            return trueIndexCount
        }
        
        let adsInserted = getAdsForRange(0...trueIndexCount, firstAdPosition: firstAdPosition, adMargin: adMargin)
        
        Logger.debug("Normalized position = position - adsInserted \(trueIndexCount) - \(adsInserted) original was \(trueIndexCount)")
        
        var test = trueIndexCount - min(adsInserted, adsCount)
        print("yay")
        return test
    }
    
    // Gets number of Ads In A given Section
    static internal func getNumberOfRowsForSectionIncludingAds(numOfRowsInSection: Int, totalRowsInSection: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
        Logger.debug("numOfRowsInSection \(numOfRowsInSection) totalRowsInSection \(totalRowsInSection)")

        guard numOfRowsInSection > 0 ||
        totalRowsInSection > firstAdPosition ||
            adsCount > 0 else {
                return numOfRowsInSection
        }
        
        let numOfAds = getAdsForRange(numOfRowsInSection - totalRowsInSection...totalRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)
        
        if(numOfRowsInSection == totalRowsInSection){
            return numOfRowsInSection + min(numOfAds, adsCount)
        }

        let adsInPreviousSections = getAdsForRange(0...totalRowsInSection - numOfRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)
        
        

        var temp = max(min(numOfAds, adsCount - adsInPreviousSections), 0) + numOfRowsInSection
        
        return temp
    }

    // Gets Ads for a given Range
    static internal func getAdsForRange(range: Range<Int>, firstAdPosition: Int, adMargin: Int) -> Int {
        
        if(range.last! < firstAdPosition){
            return 0
        }
        
        var adsLeft = true
        var lowerlimit = range.first!
        var upperlimit = range.last!
        
        if(range.contains(firstAdPosition)){
            lowerlimit = firstAdPosition + 1
            upperlimit += 1
        }
    
    
        
        while(adsLeft){
            if(lowerlimit % adMargin == 0){
                upperlimit += 1
            }
            
            lowerlimit += 1
            
            if(lowerlimit >= upperlimit){
                adsLeft = false
            }
        }
        
        return upperlimit - range.last!
    }

}
