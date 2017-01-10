//
//  AdUnitType.swift
//  PocketMediaNativeAds
//  Types of Ad Units to be handled by the library
//  Created by Iain Munro on 13/09/16.
//
//
import Foundation

/**
 Types of Ad Units we support. Struct, but instead a class because of compatibility with Objective-C
 */
@objc
public class AdUnit: NSObject {
    enum Size {
        case Regular
        case Big
    }
    enum View {
        case TableView
        case CollectionView
        case CustomView
    }
    let size: Size
    let view: View
    /**
     Returns a identifier of a nib file
     */
    var nibName: String {
        switch self {
            //TableView
            case self.view == View.TableView && self.size == Size.Regular: return "NativeAdTableViewCell"
            case self.view == View.TableView && self.size == Size.Big: return "NativeAdTableViewCellBig"
            //Collection View
            case self.view == View.CollectionView && self.size == Size.Regular: return "NativeAdCollectionViewCell"
            case self.view == View.CollectionView && self.size == Size.Big: return "NativeAdCollectionViewCellBig"
            //Custom View
            case self.view == View.CustomView: return "CustomAdCell"
        }
    }
    
    init(view: View, Size: Size) {
        
    }
}
