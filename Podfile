# Taken from https://github.com/artsy/eidolon/blob/master/Podfile.
inhibit_all_warnings!

platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/pocketbrain/pocketmedia-podspecs.git'
use_frameworks!

target 'PocketMediaNativeAds' do
	inherit! :search_paths
	project 'PocketMediaNativeAds.xcodeproj'
	workspace 'PocketMediaNativeAds.xcworkspace'
	podspec

	target 'PocketMediaNativeAdsTests' do
		inherit! :search_paths
	end

end

target 'PocketMediaNativeAdsExample' do
		inherit! :search_paths
		project 'PocketMediaNativeAdsExample.xcodeproj'
		workspace 'PocketMediaNativeAds.xcworkspace'
		use_frameworks!

		pod 'PocketMediaNativeAds', :path => './'
end

#Swift 2.3 compatiblity thingy
post_install do |installer|
	installer.pods_project.targets.each do |target|
	  target.build_configurations.each do |config|
	    config.build_settings['SWIFT_VERSION'] = '2.3'
	  end
	end
end
