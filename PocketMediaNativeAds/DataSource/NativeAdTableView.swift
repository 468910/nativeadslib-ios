//
//  NativeAdTableView.swift
//  Pods
//
//  Created by Iain Munro on 5/09/16.
//
//

import UIKit

public extension UITableView {
    fileprivate func GetNativeTableDataSource() -> NativeAdTableViewDataSource? {
        return self.dataSource as? NativeAdTableViewDataSource
    }

    func nativeAdsReloadData() {
        // If we have our data source. Inform it!
        if let source = GetNativeTableDataSource() {
            source.reload()
        }

        // Call original method
        self.nativeAdsReloadData()
    }

    //    var indexPathForSelectedRow: NSIndexPath? {
    //        get {
    //            if let indexPath = super.indexPathForSelectedRow {
    //                if let source = GetNativeTableDataSource() {
    //                    let normalized = source.normalize(indexPath)
    //                    return NSIndexPath(row: normalized, section: indexPath.section)
    //                }
    //            }
    //            return nil
    //        }
    //    }

    public class func swizzleNativeAds(_ instance: UITableView) {
        let aClass: AnyClass! = object_getClass(instance)
        let originalMethod = class_getInstanceMethod(aClass, #selector(UICollectionView.reloadData))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(UITableView.nativeAdsReloadData))
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
