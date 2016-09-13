//
//  File.swift
//  Pods
//
//  Created by apple on 09/09/16.
//
//

import Foundation

public class IndexRowNormalizer {

     // Calculates the true position for a given index path in the datasource meaning that it checks the position relative to all the sections.
	static internal func getTruePosistionForIndexPath(indexPath: NSIndexPath, datasource: NativeAdTableViewDataSourceProtocol) -> Int {
		if (indexPath.section == 0) {
			return indexPath.row
		}
        
        //The totalPreviousSectionsRows is the amount of rows that are in the previous sections. When we say previous sections we mean: Sections before the current section of the indexPath.
		var totalPreviousSectionsRows = 0
		for i in (0...max(indexPath.section - 1, 0)) {
			let rowsInSection = datasource.getNumberOfRowsInSection(numberOfRowsInSection: i)
			totalPreviousSectionsRows += rowsInSection
		}

		let truePath = max(totalPreviousSectionsRows - 1, 0) + indexPath.row
		Logger.debug("The true path is : \(truePath)")

		return truePath
	}

	// Normalizes Index to the Index in the original Datasource
	static internal func normalize(trueIndexCount: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
		var adsInserted = 0
		if (adsCount == 0 || trueIndexCount == 0 || firstAdPosition > trueIndexCount) {
			Logger.debug("Normalized position = position \(trueIndexCount) (original was \(trueIndexCount))")
			return trueIndexCount
		} else {
			adsInserted = min(((trueIndexCount - firstAdPosition) / adMargin) + 1, adsCount)
        }
		Logger.debug("Normalized position = position - adsInserted \(trueIndexCount - adsInserted) (original was \(trueIndexCount)")
		return trueIndexCount - adsInserted
	}

	// Gets number of Ads In A given Section
	static internal func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
        Logger.debug("numOfRowsInSection \(numOfRowsInSection) totalRowsInSection \(totalRowsInSection)")

		guard numOfRowsInSection > 0 &&
		totalRowsInSection > firstAdPosition
		&& adsCount > 0 else {
			return numOfRowsInSection
		}

		let numOfAds = getAdsForRange(numOfRowsInSection - totalRowsInSection...totalRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)

		let adsInPreviousSections = getAdsForRange(0...totalRowsInSection - numOfRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin)

		return min(numOfAds, adsCount - adsInPreviousSections) + numOfRowsInSection
	}

	// Gets Ads for a given Range
	static internal func getAdsForRange(range: Range<Int>, firstAdPosition: Int, adMargin: Int) -> Int {
		return range.filter {
			($0 % adMargin == 0) && (!(0...firstAdPosition ~= $0))
		}.count + (range.contains(firstAdPosition) ? 1 : 0)

	}

}