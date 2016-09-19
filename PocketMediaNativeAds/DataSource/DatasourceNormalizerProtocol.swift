//
//  NativeAdDatasourceNormalizerProtocol.swift
//  Pods
//
//  Created by apple on 09/09/16.
//
//

import Foundation

@objc
public protocol DatasourceNormalizerProtocol {
  func getTruePosistionInDataSource(indexPath: NSIndexPath) -> Int
}
