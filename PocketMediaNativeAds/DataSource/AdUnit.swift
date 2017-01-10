//
//  AdUnitType.swift
//  PocketMediaNativeAds
//  Types of Ad Units handled by the library. Contains the logic of figure out what nib file should be used based on the ad and the preference of the user.
//  Created by Iain Munro on 13/09/16.
//
//
import Foundation

/**
 This object is used at the datasource to figure out what nib file to use.
 */
@objc
public class AdUnit: NSObject {
    //This is not a string enum because of compatibility reasons with Objective-c
    @objc
    public enum UIType: Int {
        case TableView
        case CollectionView
        case CustomView
        var name: String {
            switch self {
            case .TableView: return "NativeAdTableViewCell"
            case .CollectionView: return "NativeAdCollectionViewCell"
            case .CustomView: return "CustomAdCell"
            }
        }
    }
    @objc
    public enum Flavour: Int {
        case Regular
        case Big
        var name: String {
            switch self {
            case .Regular: return "Regular"
            case .Big: return "Big"
            }
        }
    }
    private let type: UIType
    private var preference: Flavour = Flavour.Regular
    
    init(type: UIType) {
        self.type = type
    }
    
    public func setPreference(size: Flavour) {
        preference = size
    }
 
    private func getFlavour(ad: NativeAd) -> Flavour {
        switch(preference) {
        case .Big:
            if ad.bannerUrl() != nil {
                return preference
            }
        break
        default: break
        }
        return Flavour.Regular
    }
    
    /**
     Returns a identifier of a nib file
     */
    func getNibIdentifier(ad: NativeAd) -> String {
        return self.type.name + getFlavour(ad: ad).name
    }
    
    func getImageType() -> EImageType {
        switch(preference) {
        case .Big:
            return EImageType.bigImages
        break
        default:
            return EImageType.allImages
        }
    }
}
