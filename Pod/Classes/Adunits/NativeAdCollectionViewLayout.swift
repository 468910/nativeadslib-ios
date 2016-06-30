//
//  NativeAdCollectionViewLayout.swift
//  Pods
//
//  Created by Pocket Media on 23/06/16.
//
//

import Foundation


protocol NativeAdCollectionViewLayoutDelegate {
  
  func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                      withWidth:CGFloat) -> CGFloat
  
  func collectionView(collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  
}
public class NativeAdCollectionViewLayout : UICollectionViewFlowLayout {
  
  
  override public var itemSize: CGSize {
    set{
      
    }
    
    get{
      let numberOfColumns: CGFloat = 3
      
      let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (numberOfColumns - 1)) / numberOfColumns
      return CGSizeMake(itemWidth, itemWidth)
    }
  }
  
  public required override init() {
    super.init()
    setupLayout()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  func setupLayout(){
    self.minimumLineSpacing = 1
    self.minimumInteritemSpacing = 1
    self.scrollDirection = UICollectionViewScrollDirection.Vertical
  }
  
}