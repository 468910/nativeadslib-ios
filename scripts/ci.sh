#!/usr/bin/env bash
set -e
set -o pipefail && xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAdsTests" -sdk iphonesimulator9.3 test