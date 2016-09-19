//  NativeAdStream.swift
//  Pods
//
//  Created by Pocket Media on 25/05/16.
//
//

import Foundation
import UIKit

/**
 Used for loading Ads into an UIView.
**/
@objc
public class NativeAdStream: NSObject, NativeAdsConnectionDelegate, NativeAdStreamNormalizerProtocol {

    public var adMargin: Int = 1 {
        willSet {
            if newValue >= 1 {
                adMargin = newValue
            } else {
                adMargin = 1
            }
        }
    }
	// they are not called when variables are written to from an initializer or with a default value.
	public var firstAdPosition: Int = 0 {
		willSet {
			firstAdPosition = newValue + 1
			Logger.debug("First Ad Position Changed Preparing for Updating Ad Positions")
        }
	}
    public var minimumElementsRequiredForInsertionIntoTableView: Int = 0
	public var adUnitType: AdUnitType = .Standard
	private var adsPositionGivenByUser: [Int]?
	public var ads: [Int: NativeAd] = [Int: NativeAd]()
	public var datasource: DataSourceProtocol?
	public var view: UIView?

	@objc
    public required init(controller: UIViewController, view: UIView, adMargin: Int = 2, firstAdPosition: Int = 0, customXib: UINib? = nil, adsPositions: [Int]? = nil) {
        if customXib != nil {
            self.adUnitType = AdUnitType.Custom
        }
        if adsPositions != nil {
            self.adsPositionGivenByUser = Array(Set(adsPositions!)).sort { $0 < $1 }
        }
        self.adMargin = adMargin + 1//+ 1 because [...]
        self.firstAdPosition = firstAdPosition

        super.init()
        switch view {
            case let tableView as UITableView:
                if customXib != nil {
                    tableView.registerNib(customXib, forCellReuseIdentifier: "CustomAdCell")
                }
                self.view = tableView
                datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: self)
                break
//            case let collectionView as UICollectionView:
//                break
            default:
                break
		}
	}

	@objc
	public func didReceiveError(error: NSError) {
        Logger.debug("There was an Error Retrieving ads", error)
	}

	@objc
	public func didReceiveResults(nativeAds: [NativeAd]) {
		if (self.firstAdPosition == 0) {
			return
		}
		if (nativeAds.isEmpty) {
			Logger.debug("No Ads Retrieved")
            return
		}
		Logger.debug("Received \(nativeAds.count) ads.")
		updateAdPositions(nativeAds)
	}

	@objc
    public func updateAdPositions(newAds: [NativeAd]) {
		if (adsPositionGivenByUser == nil) {
			updateAdPositionsWithAdFrequency(newAds)
		} else {
			updateAdPositionsWithPositionsGivenByUser(newAds)
		}
		datasource!.onUpdateDataSource()
		Logger.debug("updateAdPositions. Count: \(datasource?.numberOfElements())")
	}

	private func updateAdPositionsWithPositionsGivenByUser(newAds: [NativeAd]) {
		let orginalCount = datasource!.numberOfElements()
		var adsInserted = 0
		for ad in newAds {
			if (adsInserted >= adsPositionGivenByUser!.count) {
				break
			}

			if (adsPositionGivenByUser![adsInserted] >= orginalCount) {
				break
			}
			ads[adsPositionGivenByUser![adsInserted] - 1] = ad
			adsInserted += 1
		}

	}
	private func updateAdPositionsWithAdFrequency(newAds: [NativeAd]) {
		let orginalCount = datasource!.numberOfElements()
		var adsInserted = 0
		for ad in newAds {

			let index = (firstAdPosition - 1) + (adMargin * adsInserted)

			if (index > (orginalCount + adsInserted)) { break }
			ads[index] = ad
			adsInserted += 1
		}
	}

	@objc
	public func didUpdateNativeAd(adUnit: NativeAd) {

	}

	func isAdAtposition(indexPath: NSIndexPath) -> NativeAd? {
		let position = self.datasource!.getTruePosistionInDataSource(indexPath)
		if let val = ads[position] {
			return val
		} else {
			return nil
		}
	}

	// TODO: Maybe this can be improved after futher testing
	func normalize(indexRow: NSIndexPath) -> Int {
		let pos = IndexRowNormalizer.getTruePosistionForIndexPath(indexRow, datasource: datasource as! NativeAdTableViewDataSourceProtocol)
		return IndexRowNormalizer.normalize(pos, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: ads.count)
	}

	func getAdCount() -> Int {
		Logger.debug("Ad count = \(ads.count)")
		return ads.count
	}

    func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int) -> Int {
        return IndexRowNormalizer.getNumberOfRowsForSectionIncludingAds(numOfRowsInSection, totalRowsInSection: totalRowsInSection, firstAdPosition: firstAdPosition, adMargin: adMargin, adsCount: ads.count)
    }


    internal func clear() {
        ads.removeAll()
        datasource!.onUpdateDataSource()
    }

	@objc public func reloadAds(adPlacementToken: String, limit: UInt) {
		clear()
		self.requestAds(adPlacementToken, limit: limit)
	}

	/**
	 Method used to load native ads.
	 - adPlacementToken: to be generated in the user dashboard used to determine placement of the ads:
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(adPlacementToken: String, limit: UInt) {
		let source = datasource as! NativeAdTableViewDataSource
        clear()
        Logger.debug("Requesting ads (\(limit)) for affiliate id \(adPlacementToken)")
        let request = NativeAdsRequest(adPlacementToken: adPlacementToken, delegate: self)
        request.retrieveAds(limit, imageType: (self.adUnitType == AdUnitType.Big ? EImageType.banner : EImageType.allImages))
	}

}
