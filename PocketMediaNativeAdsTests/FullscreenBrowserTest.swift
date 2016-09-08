//
//  FullscreenBrowserTest.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 08/09/16.
//
//

import Foundation

public class MockNativeAd: NativeAd {
    private (set) var openAdUrlInForegroundCalled: Bool = false
    
    public override func openAdUrlInForeground() {
        openAdUrlInForegroundCalled = true
    }
    
}
