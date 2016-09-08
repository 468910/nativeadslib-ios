#!/usr/bin/env bash

set -e
xcodebuild -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAdsTests" -destination "platform=iOS Simulator,name=iPhone 6" test

