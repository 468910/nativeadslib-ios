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
public class NativeAdStream: NSObject, NativeAdsConnectionDelegate {

	//Positions of the ads given by the user
	private var adsPositions: [Int]?
	public var view: UIView?
    public var datasource: DataSource!
    private var requester: NativeAdsRequest!
    private var limit: UInt = 2

	@objc
    public required init(controller: UIViewController, view: UIView, adPlacementToken: String, customXib: UINib? = nil, requester: NativeAdsRequest? = nil) {
        super.init()

        if requester == nil {
            self.requester = NativeAdsRequest(adPlacementToken: adPlacementToken, delegate: self)
        } else {
            self.requester = requester
        }

        switch view {
            case let tableView as UITableView:
                if customXib != nil {
                    tableView.registerNib(customXib, forCellReuseIdentifier: "CustomAdCell")
                }
                self.view = tableView
                datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView)
                break
//            case let collectionView as UICollectionView:
//                break
            default:
                break
		}

        if customXib != nil {
            datasource?.setAdUnitType(AdUnitType.Custom)
        }
	}

    public func setAdsPositions(adsPositions: [Int]) {
        self.adsPositions = Array(Set(adsPositions)).sort { $0 < $1 }
    }

	@objc
	public func didReceiveError(error: NSError) {
        Logger.debug("There was an Error Retrieving ads", error)
	}

	@objc
	public func didReceiveResults(nativeAds: [NativeAd]) {
		if (self.datasource.firstAdPosition == 0) {
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
    private func updateAdPositions(newAds: [NativeAd]) {
		if (adsPositions == nil) {
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
			if (adsInserted >= adsPositions!.count) {
				break
			}

			if (adsPositions![adsInserted] >= orginalCount) {
				break
			}
			datasource.ads[adsPositions![adsInserted] - 1] = ad
			adsInserted += 1
		}

	}

	private func updateAdPositionsWithAdFrequency(newAds: [NativeAd]) {
		let orginalCount = datasource!.numberOfElements()
		var adsInserted = 0
		for ad in newAds {

			let index = (datasource.firstAdPosition - 1) + (datasource.adMargin * adsInserted)

			if (index > (orginalCount + adsInserted)) { break }
			datasource.ads[index] = ad
			adsInserted += 1
		}
	}

    internal func clear() {
        datasource!.ads.removeAll()
        datasource!.onUpdateDataSource()
    }

	@objc public func reloadAds() {
		clear()
		self.requestAds(self.limit)
	}

	/**
	 Method used to load native ads.
	 - adPlacementToken: to be generated in the user dashboard used to determine placement of the ads:
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(limit: UInt) {
        self.limit = limit
        clear()
        Logger.debug("Requesting ads (\(limit)) for affiliate id \(requester.adPlacementToken)")
        requester.retrieveAds(limit, imageType: (self.datasource.adUnitType == AdUnitType.Big ? EImageType.banner : EImageType.allImages))
	}
}
