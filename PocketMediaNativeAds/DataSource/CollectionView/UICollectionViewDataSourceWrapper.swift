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
private public NativeAdCollectionViewDataSourceProtocol {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func numberOfSections(in collectionView: UICollectionView) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
}
