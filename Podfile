# Taken from https://github.com/artsy/eidolon/blob/master/Podfile.
# Yep.
inhibit_all_warnings!

platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/pocketbrain/pocketmedia-podspecs.git'

use_frameworks!


target 'PocketMediaNativeAds' do
  pod 'HanekeSwift', '~> 0.10.1'

	target 'PocketMediaNativeAdsTests' do
	  pod 'HanekeSwift', '~> 0.10.1'
	  inherit! :search_paths
	end

end