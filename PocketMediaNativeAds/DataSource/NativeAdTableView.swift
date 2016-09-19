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
                if let source = self.dataSource as? NativeAdTableViewDataSource {
                    let normalized = source.normalize(indexPath)
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
