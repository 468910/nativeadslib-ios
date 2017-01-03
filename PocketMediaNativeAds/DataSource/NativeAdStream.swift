//  NativeAdStream.swift
//  Pods
//
//  Created by Pocket Media on 25/05/16.
//

import UIKit

/**
 This class is the entry point of easily integrating nativeAds in existing UI elements of the host.
 */
@objc
open class NativeAdStream: NSObject, NativeAdsConnectionDelegate {

    /// The view we're going to integrate the native ads in.
    open var view: UIView?
    /// The mixed datasource
    open var datasource: DataSource!
    /// The instance of a requester which we'll use to do the network requests.
    fileprivate var requester: NativeAdsRequest!
    /// The amount of ads previously requested. (Due to the fact that we can reload without redefining the amount)
    fileprivate var limit: UInt = 2

    /**
     Initializer of the Native Ad Stream way of implementing ads in existing UI Views.
     The following UI elements are supported:
     - parameter controller: Current controller. So we have context of where the ad click is coming from. (Used for example to get from an ad click)
     - parameter view: The actual view that needs to integrate the ads.
     - paramater adPlacementToken: The placement token received from http://third-party.pmgbrain.com/
     - parameter customXib: UINib instance that will be used instead of the StandardAdUnitTableViewCell.
     - parameter adPosition: Instance that conforms to the AdPosition protocol. Dictating where an ad should show.
     - parameter requester: Instance of NativeAdsRequest. We'll create a new instance if nil
     */
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

        self.view = view

        // Depending on the view that was sent along, use one of our known implementations.
        switch view {
        case let tableView as UITableView:

            // If a custom xib was sent. Register it.
            if customXib != nil {
                if tableView.dequeueReusableCell(withIdentifier: "CustomAdCell") == nil {
                    tableView.register(customXib, forCellReuseIdentifier: "CustomAdCell")
                }
            }

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
    /**
     This method is called if something goes wrong retrieving the ads.s
     */
    open func didReceiveError(_ error: Error) {
        Logger.debug("There was an error retrieving ads", error)
    }

    /**
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

    /**
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
