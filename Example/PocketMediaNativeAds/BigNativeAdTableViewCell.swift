//
//  BigNativeAdTableViewCell.swift
//  Pods
//
//  Created by apple on 23/02/16.
//
//

import UIKit

/**
*/
public class BigNativeAdTableViewCell : UITableViewCell {
 
  @IBOutlet weak var adImage: UIImageView!
  
  @IBOutlet weak var adTitle: UILabel!
  
  /**
  //Objective C initWithStyle
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    print("Using style: reuseIdentifier:")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    print(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
  }*/
  
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    print("Awakening from NIB")
    
    
    
   // adImage.image = UIImage(named: "Highlight-St.-Barts-Image.jpg")
    adImage.clipsToBounds = true
    //adImage.addSubview(adTitle)
    
    adTitle.text = "Super";
    adTitle.lineBreakMode = .ByWordWrapping
    print("Awakend from NIB")
  }
  
  
  
  required public init?(coder aDecoder: NSCoder){
    print("Using coder:")
    super.init(coder: aDecoder)
    //self.translatesAutoresizingMaskIntoConstraints = false
  }
 
}