//
//  AdUnitFactory.swift
//  Pods
//
//  Created by apple on 09/03/16.
//
//
@objc
public class AdUnitFactory : NSObject {
  
  static var bundle : NSBundle = PocketMediaNativeAdsBundle.loadBundle()!
  
  /**
  */
  @objc
  static public func constructAbstractAdUnitUIView(nativeAd: NativeAd) -> AbstractAdUnitUIView{
    let adunit : AbstractAdUnitUIView  = bundle.loadNibNamed("NativeAdView", owner: self, options: nil)[0] as! AbstractAdUnitUIView
    adunit.configureAdView(nativeAd)
    return adunit
  }
  
  @objc
  static public func constructAbstractAdUnitUIView(nativeAd: NativeAd, viewController: UIViewController) -> AbstractAdUnitUIView{
    let adunit : AbstractAdUnitUIView  = bundle.loadNibNamed("NativeAdView", owner: self, options: nil)[0] as! AbstractAdUnitUIView
    adunit.configureAdView(nativeAd, viewController: viewController)
    return adunit
  }
  
  
}