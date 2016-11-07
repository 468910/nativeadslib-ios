//  NativeAdStream.swift
//  Pods
//
//  Created by Pocket Media on 25/05/16.
//  This class is the entry point of easily integrating nativeAds in existing UI elements of the host.
//

import UIKit

/**
 Used for loading Ads into an UIView.
 **/
@objc
open class NativeAdStream: NSObject, NativeAdsConnectionDelegate {

    open var view: UIView?
    open var datasource: DataSource!
    fileprivate var requester: NativeAdsRequest!
    fileprivate var limit: UInt = 2

    @objc
    public required init(
        controller: UIViewController,
        view: UIView,
        adPlacementToken: String,
        customXib: UINib? = nil,
        adPosition: AdPosition? = MarginAdPosition(margin: 2),
        requester: NativeAdsRequest? = nil
    ) {
        super.init()

        // Create a new instance of a requester or use the one sent along. This is done for unit testing purposes.
        if requester == nil {
            self.requester = NativeAdsRequest(adPlacementToken: adPlacementToken, delegate: self)
        } else {
            self.requester = requester
        }

        // Depending on the view that was sent along, use one of our known implementations.
        switch view {
        case let tableView as UITableView:

            // If a custom xib was sent. Register it.
            if customXib != nil {
                if tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil {
                    tableView.register(customXib, forCellReuseIdentifier: "CustomAdCell")
                }
            }

            self.view = tableView
            datasource = NativeAdTableViewDataSource(controller: controller, tableView: tableView, adPosition: adPosition!)
            break
            //            case let collectionView as UICollectionView:
            //                break
        default:
            datasource = DataSource()
            break
        }

        // If a custom XIB was sent along. Set the adUnitType to custom
        if customXib != nil {
            datasource?.adUnitType = AdUnitType.custom
        }
    }

    @objc
    open func didReceiveError(_ error: Error) {
        Logger.debug("There was an Error Retrieving ads", error)
    }

    /*
     * This method is called when we hear back from the server.
     */
    @objc
    open func didReceiveResults(_ newAds: [NativeAd]) {
        if newAds.count < 0 {
            Logger.debug("Received no Ads")
        }
        Logger.debug("Received \(newAds.count) new ads.")
        datasource!.onAdRequestSuccess(newAds)
    }

    /*
     * This method reloads the known ads.
     */
    @objc open func reloadAds() {
        self.requestAds(self.limit)
    }

    /**
     Method used to load native ads.
     - limit: Limit on how many native ads are to be retrieved.
     */
    @objc open func requestAds(_ limit: UInt, adUnitType: AdUnitType = AdUnitType.standard) {
        // Set the limit so that when the user does a reloadAds call we know what limit they want.
        self.limit = limit

        if self.datasource.adUnitType != AdUnitType.custom {
            self.datasource.adUnitType = adUnitType
        }

        Logger.debug("Requesting ads (\(limit)) for affiliate id \(requester.adPlacementToken)")

        var imageType = EImageType.allImages
        // If our adunit is of the type Big. Then let us ask our api to send back banner like images
        if self.datasource.adUnitType == AdUnitType.big {
            imageType = EImageType.banner
        }

        requester.retrieveAds(limit, imageType: imageType)
    }
}
