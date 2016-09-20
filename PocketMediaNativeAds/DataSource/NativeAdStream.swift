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

	public var view: UIView?
    public var datasource: DataSource!
    private var requester: NativeAdsRequest!
    private var limit: UInt = 2

    private var _adsPositions: [Int]? = nil
    //Positions of the ads given by the user
    public var adsPositions: [Int]? {
        set {
            if newValue != nil {
                _adsPositions = Array(Set(newValue!)).sort { $0 < $1 }
            }
        }
        get {
            return _adsPositions
        }
    }

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
                datasource = DataSource()
                break
		}

        if customXib != nil {
            datasource?.adUnitType = AdUnitType.Custom
        }
	}

    public func setAdMargin(value: Int = 3) {
        self.datasource.adMargin = value
    }

    public func setFirstAdPosition(value: Int = 0) {
        self.datasource.firstAdPosition = value
    }

	@objc
	public func didReceiveError(error: NSError) {
        Logger.debug("There was an Error Retrieving ads", error)
	}

	@objc
	public func didReceiveResults(newAds: [NativeAd]) {
		Logger.debug("Received \(newAds.count) new ads.")
		
        //Clear any existing ads
        clear()
        let orginalCount = datasource!.numberOfElements()
        var adsInserted = 0
        for ad in newAds {
            if (adsPositions == nil) {
                let index = (datasource.firstAdPosition - 1) + (datasource.adMargin * adsInserted)
                if (index > (orginalCount + adsInserted)) {
                    break
                }
                datasource.ads[index] = ad
            } else {
                if (adsInserted >= adsPositions!.count) {
                    break
                }
                if (adsPositions![adsInserted] >= orginalCount) {
                    break
                }
                datasource.ads[adsPositions![adsInserted] - 1] = ad
            }
            adsInserted += 1
        }
        
        if adsInserted > 0 {
            datasource!.onUpdateDataSource()
        }
        Logger.debug("updateAdPositions. Count: \(datasource?.numberOfElements())")
    }

    internal func clear() {
        datasource!.ads.removeAll()
        datasource!.onUpdateDataSource()
    }

	@objc public func reloadAds() {
		self.requestAds(self.limit)
	}

	/**
	 Method used to load native ads.
	 - adPlacementToken: to be generated in the user dashboard used to determine placement of the ads:
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(limit: UInt) {
        self.limit = limit
        Logger.debug("Requesting ads (\(limit)) for affiliate id \(requester.adPlacementToken)")
        requester.retrieveAds(limit, imageType: (self.datasource.adUnitType == AdUnitType.Big ? EImageType.banner : EImageType.allImages))
	}
}
