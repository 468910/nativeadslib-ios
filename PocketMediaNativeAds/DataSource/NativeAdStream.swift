//  NativeAdStream.swift
//  Pods
//
//  Created by Pocket Media on 25/05/16.
//  This class is the entry point of easily integrating nativeAds in existing UI elements of the host.
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

    /*
     * This sets the adsPositions within the datasource. In other words this sets the positions (indexes) of where the ads are supposed to be.
     */
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
        
        //Create a new instance of a requester or use the one sent along. This is done for unit testing purposes.
        if requester == nil {
            self.requester = NativeAdsRequest(adPlacementToken: adPlacementToken, delegate: self)
        } else {
            self.requester = requester
        }
        
        //Depending on the view that was sent along, use one of our known implementations.
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
        
        //If a custom XIB was sent along. Set the adUnitType to custom
        if customXib != nil {
            datasource?.adUnitType = AdUnitType.Custom
        }
	}
    
    /*
     * This sets the adMargin within the datasource. In other words this sets the frequency of the ads.
     */
    public func setAdMargin(value: Int = 3) {
        self.datasource.adMargin = value
    }

    /*
     * This sets the firstAdPosition within the datasource. In other words this sets the position of the first ad.
     */
    public func setFirstAdPosition(value: Int = 1) {
        self.datasource.firstAdPosition = value
    }
    
	@objc
	public func didReceiveError(error: NSError) {
        Logger.debug("There was an Error Retrieving ads", error)
	}
    
    /*
    * This method is called when we hear back from the server.
    */
	@objc
	public func didReceiveResults(newAds: [NativeAd]) {
		Logger.debug("Received \(newAds.count) new ads.")
        //Clear any existing ads
        clear()
        
        //Loop through each new ad and depending on our adding strategy add it to our datasource.ads
        
        let originalCount = datasource!.numberOfElements()
        if(datasource.firstAdPosition > originalCount) {
            Logger.debug("FirstAdPosition exceeds numberOfElements")
            return
        }
        
        if(adsPositions != nil){
            let filterAdPositions = adsPositions!.filter( {
                $0 <= min(newAds.count, datasource!.adMargin / (originalCount - datasource.firstAdPosition))
                    * datasource!.adMargin})
            
            for position in filterAdPositions {
                for i in 0..<filterAdPositions.count {
                    datasource.ads[position] = newAds[i]
                }
            }
        }
        else { 
        
        // Get the minimum of Received ads vs Max amount of ads to insert
        let numOfAdsToInsert = min(newAds.count, ((originalCount - datasource.firstAdPosition) / datasource!.adMargin) + 1)
    
            for i in 0..<numOfAdsToInsert{
                datasource.ads[(datasource.firstAdPosition) + (datasource.adMargin * i)] = newAds[i]
            }
        }
        datasource!.onUpdateDataSource()
        
        Logger.debug("updateAdPositions. Count: \(datasource?.numberOfElements())")
    }
    
    /*
     * This method clears the ads in the datasource and informs the datasource about this.
     */
    internal func clear() {
        datasource!.ads.removeAll()
        datasource!.onUpdateDataSource()
    }
    
    /*
     * This method reloads the known ads.
     */
	@objc public func reloadAds() {
		self.requestAds(self.limit)
	}

	/**
	 Method used to load native ads.
	 - limit: Limit on how many native ads are to be retrieved.
	 */
	@objc public func requestAds(limit: UInt) {
        //Set the limit so that when the user does a reloadAds call we know what limit they want.
        self.limit = limit
        Logger.debug("Requesting ads (\(limit)) for affiliate id \(requester.adPlacementToken)")
        
        var imageType = EImageType.allImages
        //If our adunit is of the type Big. Then let us ask our api to send back banner like images
        if self.datasource.adUnitType == AdUnitType.Big {
            imageType = EImageType.banner
        }
        
        requester.retrieveAds(limit, imageType: imageType)
	}
}
