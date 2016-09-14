#!/usr/bin/env bash
set -e
set -o pipefail && xcodebuild -verbose -workspace PocketMediaNativeAds.xcworkspace -scheme "PocketMediaNativeAds Library - Unit tests" -sdk iphonesimulator9.3 test