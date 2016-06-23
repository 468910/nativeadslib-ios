//
//  NativeAdCollectionCell.swift
//  Pods
//
//  Created by apple on 23/06/16.
//
//

import Foundation
import UIKit

public class NativeAdCollectionCell : UICollectionViewCell {
  @IBOutlet weak var speakerPhone : UIImageView!
  @IBOutlet weak var adImage : UIImageView!
  @IBOutlet weak var adTitle: UILabel!
  @IBOutlet weak var adDescription : UILabel!
  
   public override func awakeFromNib() {
    super.awakeFromNib()
   }
  
}