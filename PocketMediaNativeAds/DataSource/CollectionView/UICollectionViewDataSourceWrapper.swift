//
//  NativeAdCollectionViewDataSourceProtocol.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 10/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 This procol defines what Apple requires us to implement. Based on https://developer.apple.com/reference/uikit/uicollectionviewdatasource
 This makes sure we don't miss a method. Because all methods should be implemented, even the optional ones.
 */
public protocol UICollectionViewDataSourceWrapper {
    /**
     Required. Asks your data source object for the number of items in the specified section.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    /**
     Asks your data source object for the number of sections in the collection view.
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int
    /**
     Required. Asks your data source object for the cell that corresponds to the specified item in the collection view.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    /**
     Asks your data source object to provide a supplementary view to display in the collection view.
     */
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    /**
     Asks your data source object whether the specified item can be moved to another location in the collection view.
     */
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    /**
     Tells your data source object to move the specified item to its new location.
     */
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}
