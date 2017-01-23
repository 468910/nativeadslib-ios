//
//  NativeAdTableView.swift
//  Pods
//
//  Created by Iain Munro on 5/09/16.
//
//

import UIKit

/**
 This extension swizzles the reloadData call for example so we can do some calculations if the data in the datasource changes.
 */
public extension UITableView {
    /**
     Returns the datasource if it is our wrapped one.
     */
    fileprivate func GetNativeTableDataSource() -> NativeAdTableViewDataSource? {
        return self.dataSource as? NativeAdTableViewDataSource
    }

    /**
     If we have our data source. Inform it that we're reloading the data. (Different positions and such)
     */
    func nativeAdsReloadData() {
        // If we have our data source. Inform it!
        if let source = GetNativeTableDataSource() {
            source.reload()
        }

        // Call original method
        self.nativeAdsReloadData()
    }

    /**
     Starts the swizzling of the datasource.
     */
    public class func swizzleNativeAds(_ instance: UITableView) {
        let aClass: AnyClass! = object_getClass(instance)
        let originalMethod = class_getInstanceMethod(aClass, #selector(UICollectionView.reloadData))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(UITableView.nativeAdsReloadData))
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
