//
//  NativeAdCollectionViewDelegate.swift
//  Pods
//
//  Created by Pocket Media on 22/06/16.
//
//

import UIKit
import Foundation

public class NativeAdCollectionViewDelegate: NSObject, UICollectionViewDelegate {

	public var controller: UIViewController
	public var delegate: UICollectionViewDelegate
	public var datasource: NativeAdCollectionViewDataSource

	required public init(datasource: NativeAdCollectionViewDataSource, controller: UIViewController, delegate: UICollectionViewDelegate) {
		self.datasource = datasource
		self.controller = controller
		self.delegate = delegate
	}

	public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

		if let val = datasource.adStream.isAdAtposition(indexPath) {
			val.openAdUrl(FullscreenBrowser(parentViewController: controller))
		} else {
			return delegate.collectionView!(collectionView, didSelectItemAtIndexPath: indexPath)
		}
	}

}