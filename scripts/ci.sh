#!/usr/bin/env bash
set -e
set -o pipefail && xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAdsTests" clean
sleep 2
set -o pipefail && xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAdsTests" -destination "platform=iOS Simulator,name=iPhone 6" test