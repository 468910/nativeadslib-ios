//
//  UIViewController.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 30/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 This extension is to allow for some common methods used throughout the library.
 */
public extension UIViewController {
    public func setRootView(view: UIViewController) {
        if let window = UIApplication.shared.keyWindow {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = view
                UIView.setAnimationsEnabled(oldState)
            }, completion: nil)
        }
    }
}
