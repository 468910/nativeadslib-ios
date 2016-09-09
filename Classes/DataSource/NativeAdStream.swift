
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

	static internal var viewRegister = Array<String>()
	public var adMargin: Int?
	public var debugModeEnabled: Bool = false
	public static var adStreamRegister: [String: NativeAdStream] = [:]
	public var minimumElementsRequiredForInsertionIntoTableView: Int = 0

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
		case Custom
	}

	public var adUnitType: AdUnitType = .Standard
	private var adsPositionGivenByUser: [Int]?
	public var ads: [Int: NativeAd]
	public var datasource: DataSourceProtocol?
	public var tempAds: [NativeAd]
	public var mainView: UIView?

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adMargin: Int) {
		self.init(controller: controller, mainView: mainView, adMargin: adMargin, firstAdPosition: adMargin)
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adMargin: Int, firstAdPosition: Int, customXib: UINib) {

		self.init(controller: controller, mainView: mainView, customXib: customXib)
		self.firstAdPosition = firstAdPosition
		self.adMargin = adMargin + 1
		self.adUnitType = .Custom
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, adsPositions: [Int], customXib: UINib) {
		self.init(controller: controller, mainView: mainView, customXib: customXib)
		self.adsPositionGivenByUser = Array(Set(adsPositions)).sort { $0 < $1 }
		self.adUnitType = .Custom
	}

	@objc
	public convenience init(controller: UIViewController, mainView: UIView, customXib: UINib) {
		switch mainView {
		case let tableView as UITableView:
			tableView.registerNib(customXib, forCellReuseIdentifier: "CustomAdCell")
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

		if (NativeAdStream.viewRegister.contains(mainView.objectName)) {
			let view = mainView as! UITableView
			self.mainView = view
			datasource = view.dataSource as! NativeAdTableViewDataSource
			datasource!.attachAdStream(self)

		} else {

			self.mainView = mainView
			switch mainView {
			case let tableView as UITableView:

				object_setClass(tableView, NativeAdTableView.self)

				self.mainView = tableView
				datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adStream: self)

				print(tableView)

				NativeAdStream.adStreamRegister[tableView.objectName] = self
				NativeAdStream.viewRegister.append(tableView.objectName)
				break
			case let collectionView as UICollectionView:
				datasource = NativeAdCollectionViewDataSource(controller: controller, collectionView: collectionView, adStream: self)
			default:
				break
			}

		}

	}

	deinit {
		if ((NativeAdStream.adStreamRegister[self.mainView!.objectName] == self)) {
			object_setClass(mainView, NativeAdTableView.self)
		}
		print("Adstream being Cleared")
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

		if (debugModeEnabled) {
			NSLog("Number of Ads retrieved 🐶 \(nativeAds.count)");
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

	func normalize(indexRow: Int) -> Int {
		var adsInserted = 0
		var adsCount = ads.count

		if (adsCount == 0 || indexRow == 0 || firstAdPosition > indexRow) {

			NSLog("Normalized position = position \(indexRow) (original was \(indexRow))")

			return indexRow

		} else {

			var temp = min(((indexRow - firstAdPosition!) / self.adMargin!) + 1, adsCount)
			adsInserted = min(((indexRow - firstAdPosition!) / self.adMargin!) + 1, adsCount)
		}
		/*
		 if (debugModeEnabled) {
		 NSLog("Normalized position = position - adsInserted \(position - adsInserted) (original was \(position)")
		 }*/

		return indexRow - adsInserted

	}

	func getAdCount() -> Int {
		if (debugModeEnabled) {
			NSLog("Ad count = \(ads.count)")
		}
		return ads.count
	}

	func getCountForSection(numOfRowsInSection: Int, totalRowsInSection: Int) -> Int {
		if (debugModeEnabled) {
			print("numOfRowsInSection \(numOfRowsInSection) totalRowsInSection \(totalRowsInSection)")
		}

		guard numOfRowsInSection > 0 &&
		totalRowsInSection > firstAdPosition!
		&& ads.count > 0 else {
			return numOfRowsInSection
		}

		var numOfAds = getAdsForRange(numOfRowsInSection - totalRowsInSection...totalRowsInSection)
		var adsInPreviousSections = getAdsForRange(0...totalRowsInSection - numOfRowsInSection)

		return min(numOfAds, ads.count - adsInPreviousSections) + numOfRowsInSection

	}
    
    @objc
    public func didReceiveError(error: NSError) {
        NSLog("Error receiving ads.")
    }

	private func getAdsForRange(range: Range<Int>) -> Int {
		return range.filter {
			($0 % adMargin! == 0) && (!(0...firstAdPosition! ~= $0))
		}.count + (range.contains(firstAdPosition!) ? 1 : 0)

	}

	@objc public func clearAdStream(affiliateId: String, limit: UInt) {

		if (debugModeEnabled) {
			NSLog("Clearing Ad stream.")
		}

		self.ads = [Int: NativeAd]()
		self.requestAds(affiliateId, limit: limit)
		datasource?.onUpdateDataSource()
	}

	/**
	 Method used to load native ads.
	 - adPlacementToken: to be generated in the user dashboard used to determine placement of the ads:
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(affiliateId: String, limit: UInt) {
		var source = datasource as! NativeAdTableViewDataSource

		if (!ads.isEmpty) {
			ads.removeAll()
			tempAds.removeAll()
			datasource!.onUpdateDataSource()
		}

		source.completion = { () in
			guard limit > 0 &&
			self.datasource!.numberOfElements() > self.minimumElementsRequiredForInsertionIntoTableView else {
				self.datasource?.onUpdateDataSource()
				return
			}
			var numOfElements = self.datasource!.numberOfElements()
			self.ads = [Int: NativeAd]()
			self.tempAds = [NativeAd]()
			self.datasource?.onUpdateDataSource()

			if (self.debugModeEnabled) {
				NSLog("Requesting ads (\(limit)) for affiliate id \(affiliateId)")
			}

			var request = NativeAdsRequest(adPlacementToken: affiliateId, delegate: self)
			request.debugModeEnabled = self.debugModeEnabled

			request.retrieveAds(limit, imageType: EImageType.allImages)
		}

	}

}

