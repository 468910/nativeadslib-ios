# Taken from https://github.com/artsy/eidolon/blob/master/Podfile.
# Yep.
inhibit_all_warnings!

platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/pocketbrain/pocketmedia-podspecs.git'

use_frameworks!

target 'PocketMediaNativeAds' do
	project 'PocketMediaNativeAds.xcodeproj'
	workspace 'PocketMediaNativeAds.xcworkspace'

	target 'PocketMediaNativeAdsTests' do
	  inherit! :search_paths
	end

	target 'PocketMediaNativeAdsExample' do
	    inherit! :search_paths
	    project 'PocketMediaNativeAdsExample.xcodeproj'
	    pod 'PocketMediaNativeAds', :path => './'
	end
end
