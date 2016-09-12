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
	static func getTruePosistionForIndexPath(indexPath: NSIndexPath, datasource: NativeAdTableViewDataSourceProtocol) -> Int {
		if (indexPath.section == 0) {
			return indexPath.row
		}

		var totalRows = 0
		for i in (0...max(indexPath.section - 1, 0)) {
			let rowsInSection = datasource.getNumberOfRowsInSection(numberOfRowsInSection: i)
			totalRows += rowsInSection
		}

		let truePath = max(totalRows - 1, 0) + indexPath.row
		print("The true path is : \(truePath)")

		return max(totalRows - 1, 0) + indexPath.row
	}

	// Normalizes Index to the Index in the original Datasource
	static func normalize(indexRow: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
		var adsInserted = 0

		if (adsCount == 0 || indexRow == 0 || firstAdPosition > indexRow) {

			Logger.debug("Normalized position = position \(indexRow) (original was \(indexRow))")

			return indexRow

		} else {

			adsInserted = min(((indexRow - firstAdPosition) / adMargin) + 1, adsCount)
		}

		Logger.debug("Normalized position = position - adsInserted \(indexRow - adsInserted) (original was \(indexRow)")

		return indexRow - adsInserted
	}

	// Gets number of Ads In A given Section
	static func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int, firstAdPosition: Int, adMargin: Int, adsCount: Int) -> Int {
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
	static func getAdsForRange(range: Range<Int>, firstAdPosition: Int, adMargin: Int) -> Int {
		return range.filter {
			($0 % adMargin == 0) && (!(0...firstAdPosition ~= $0))
		}.count + (range.contains(firstAdPosition) ? 1 : 0)

	}

}