
//  NativeAdStream.swift
//  Pods
//
//  Created by Pocket Media on 25/05/16.
//
//

import Foundation

/**
 Used for loading Ads into an UIView.
 **/

@objc
public class NativeAdStream: NSObject, NativeAdsConnectionDelegate {

	public var adMargin: Int?
	public var debugModeEnabled: Bool = false

	// they are not called when variables are written to from an initializer or with a default value.
	public var firstAdPosition: Int? {
		willSet {
			firstAdPosition = newValue! + 1
			if (debugModeEnabled) {
				NSLog("First Ad Position Changed Preparing for Updating Ad Positions")
			}
		}

		didSet {
			if firstAdPosition != oldValue {
				updateAdPositions()
			}
		}
	}

	public enum AdUnitType {
		case Standard
		case Big
		case CustomStandard
		case CustomBig
	}

	public var adUnitType: AdUnitType = .Big
	private var adsPositionGivenByUser: [Int]?
	private var ads: [Int: NativeAd]
	public var datasource: DataSourceProtocol?
	public var tempAds: [NativeAd]

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adMargin: Int) {
		self.init(controller: controller, mainView: mainView, adMargin: adMargin, firstAdPosition: adMargin)
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adMargin: Int, firstAdPosition: Int, customXib: UINib) {

		self.init(controller: controller, mainView: mainView, customXib: customXib)
		self.firstAdPosition = firstAdPosition
		self.adMargin = adMargin + 1
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adsPositions: [Int], customXib: UINib) {

		self.init(controller: controller, mainView: mainView, customXib: customXib)
		self.adsPositionGivenByUser = Array(Set(adsPositions)).sort { $0 < $1 }
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, customXib: UINib) {
		switch mainView {
		case let tableView as UITableView:
			tableView.registerNib(customXib, forCellReuseIdentifier: "NativeAdTableViewCell")
			self.init(controller: controller, mainView: tableView)
			break
		case let collectionView as UICollectionView:
			self.init(controller: controller, mainView: collectionView)
			break
		default:
			self.init(controller: controller, mainView: mainView)
			break
		}

	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adsPositions: [Int]) {
		self.init(controller: controller, mainView: mainView)
		self.firstAdPosition = adsPositions.minElement()
		self.adsPositionGivenByUser = Array(Set(adsPositions)).sort { $0 < $1 }
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adMargin: Int, firstAdPosition: Int) {
		self.init(controller: controller, mainView: mainView)
		self.adMargin = adMargin + 1
		self.firstAdPosition = firstAdPosition
	}

	@objc
	public required init(controller: UIViewController, mainView: UIView) {

		self.ads = [Int: NativeAd]()
		self.tempAds = [NativeAd]()
		super.init()

		switch mainView {
		case let tableView as UITableView:
			datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: self)
			break
		case let collectionView as UICollectionView:
			datasource = NativeAdCollectionViewDataSource(controller: controller, collectionView: collectionView, adStream: self)
		default:
			break
		}

	}

	@objc
	public func didRecieveError(error: NSError) {

	}

	@objc
	public func didReceiveResults(nativeAds: [NativeAd]) {

		if (self.adMargin < 1 && self.adMargin != nil) {
			return
		}

		if (self.firstAdPosition == 0) {
			return
		}

		if (nativeAds.isEmpty) {
			if (debugModeEnabled) {
				NSLog("No Ads Retrieved")
			}
		}

		self.tempAds = nativeAds

		updateAdPositions()

	}

	@objc
	public func updateAdPositions() {

		if (adsPositionGivenByUser == nil) {
			updateAdPositionsWithAdFrequency()
		} else {
			updateAdPositionsWithPositionsGivenByUser()
		}

		datasource!.onUpdateDataSource()
		if (debugModeEnabled) {
			NSLog("udateAdPositions. Count: \(datasource?.numberOfElements())")
		}
	}

	private func updateAdPositionsWithPositionsGivenByUser() {

		var orginalCount = datasource!.numberOfElements()

		var adsInserted = 0
		for ad in tempAds {
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
	private func updateAdPositionsWithAdFrequency() {
		var orginalCount = datasource!.numberOfElements()

		var adsInserted = 0

		for ad in tempAds {

			var index = (firstAdPosition! - 1) + (adMargin! * adsInserted)

			if (index > (orginalCount + adsInserted)) { break }
			ads[index] = ad
			adsInserted += 1
		}
		var tempads = ads
	}

	@objc
	public func didUpdateNativeAd(adUnit: NativeAd) {

	}

	func isAdAtposition(position: Int) -> NativeAd? {
		if let val = ads[position] {
			return val
		} else {
			return nil
		}
	}

	func normalize(position: Int) -> Int {

		var adsInserted = 0

		if (adsPositionGivenByUser != nil) {

			for pos in adsPositionGivenByUser! {

				if ((pos - 1) < position) {
					adsInserted += 1
				}
			}

		}

		if (ads.isEmpty || position == 0 || firstAdPosition! > position) {

			NSLog("Normalized position = position \(position) (original was \(position))")
			return position

		} else {

			adsInserted = 1

			if ((position - firstAdPosition!) >= adMargin!) {
				adsInserted += (position - firstAdPosition!) / adMargin!
			}

			if (adsInserted > ads.count) {
				adsInserted = ads.count
			}

		}

		if (debugModeEnabled) {
			NSLog("Normalized position = position - adsInserted \(position - adsInserted) (original was \(position)")
		}

		return position - adsInserted

	}

	func getAdCount() -> Int {
		if (debugModeEnabled) {
			NSLog("Ad count = \(ads.count)")
		}
		return ads.count
	}

	@objc public func clearAdStream(affiliateId: String, limit: UInt) {

		if (debugModeEnabled) {
			NSLog("Clearing Ad stream.")
		}

		ads = [:]
		self.requestAds(affiliateId, limit: limit)
		datasource?.onUpdateDataSource()
	}

	/**
	 Method used to load native ads.
	 - adPlacementToken: to be generated in the user dashboard used to determine placement of the ads:
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(affiliateId: String, limit: UInt) {

		if (debugModeEnabled) {
			NSLog("Requesting ads (\(limit)) for affiliate id \(affiliateId)")
		}

		var request = NativeAdsRequest(adPlacementToken: affiliateId, delegate: self)
		request.debugModeEnabled = self.debugModeEnabled

		switch (self.adUnitType) {
		case .Big:
			request.imageFilter = NativeAdsRequest.imageType.banner
			break
		case .Standard:
			break
		default:
			break
		}

		request.retrieveAds(limit)
	}

}
