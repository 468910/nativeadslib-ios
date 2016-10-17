#!/usr/bin/env bash
#Run this from the project root.
xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAds Library - Unit tests" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone Retina (4-inch)' test
