//
//  MoPubTableViewController.swift
//  PocketMediaNativeAdsExample
//
//  Created by Iain Munro on 23/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation
import MoPub

/**
 Example of a default MoPub integration. No reference to PocketMedia. This is all done in the MoPub web dashboard
*/
class MoPubTableViewController: UITableViewController {
    
    var placer: MPTableViewAdPlacer!
    var tableViewDataSource: ExampleTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewDataSource = ExampleTableViewDataSource()
        tableViewDataSource?.loadLocalJSON()
        tableView.dataSource = tableViewDataSource
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.refresh(refreshControl:)), for: UIControlEvents.valueChanged)
        
        // Create the Static Native Ad renderer configuration.
        let staticSettings = MPStaticNativeAdRendererSettings()
        staticSettings.renderingViewClass = MoPubNativeAdCell.self
        
        
        staticSettings.viewSizeHandler = { (maxWidth: CGFloat) -> CGSize in
            return CGSize(width: maxWidth, height: 110)
        }
        let staticConfiguration = MPStaticNativeAdRenderer.rendererConfiguration(with: staticSettings)
        staticConfiguration?.supportedCustomEvents = ["PMMoPubNativeCustomEvent"]
        
        // Setup the ad placer.
        placer = MPTableViewAdPlacer(tableView: tableView, viewController: self, rendererConfigurations: [staticConfiguration as Any])
        
        // Add targeting parameters.
        let targeting = MPNativeAdRequestTargeting()
        targeting.desiredAssets = Set([kAdIconImageKey, kAdCTATextKey, kAdTextKey, kAdTitleKey])//kAdMainImageKey
        
        // Begin loading ads and placing them into your feed, using the ad unit ID.
        placer.loadAds(forAdUnitID: "23b59fd707994fc589702e7785f84e3c")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc
    public func refresh(refreshControl: UIRefreshControl) {
        placer.loadAds(forAdUnitID: "23b59fd707994fc589702e7785f84e3c")
        refreshControl.endRefreshing()
    }
    
}
