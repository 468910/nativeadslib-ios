//
//  NativeAdTableView.swift
//  Pods
//
//  Created by apple on 12/08/16.
//
//

import UIKit

public class NativeAdTableView: UITableView {
	override public var indexPathForSelectedRow: NSIndexPath? {
		get {
			if let indexPath = super.indexPathForSelectedRow {
                let source = self.dataSource as? NativeAdTableViewDataSource
                if let source = self.dataSource as? NativeAdTableViewDataSource {
                    let normalized = source.adStream.normalize(indexPath)
                    return NSIndexPath(forRow: normalized, inSection: indexPath.section)
                }
			}
            return nil
		}
	}
}

public extension UIView {
	var objectName: String {
		return String(ObjectIdentifier(self).uintValue)
	}
}
