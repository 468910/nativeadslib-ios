#!/usr/bin/env bash
set -e
set -o pipefail && xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAdsTests" -destination "platform=iOS Simulator,name=iPhone 6" clean analyze test