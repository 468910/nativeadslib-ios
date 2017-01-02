# Taken from https://github.com/artsy/eidolon/blob/master/Podfile.
inhibit_all_warnings!

platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Pocketbrain/nativeadslib-ios.git'
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

# https://stackoverflow.com/a/38466703/570087
post_install do |installer|
  installer.pods_project.targets.each  do |target|
      target.build_configurations.each  do |config| config.build_settings['SWIFT_VERSION'] = '3.0'
      end
   end
end
