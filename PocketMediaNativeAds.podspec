#
# Be sure to run `pod lib lint PocketMediaNativeAds.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PocketMediaNativeAds"
  s.version          = "1.0.0"
  s.summary          = "PocketMediaNativeAds allows you to integrate customizable Native Ads in your app, easily and quickly."
  s.description      = <<-DESC
With Pocket Media Native Ads you can quickstart the process of adding native ads to your iOS project.
Everything is customizable, but this library allows you to testdrive the implementation real fast.
                       DESC

s.homepage         = "http://pocketmedia.mobi"
  s.screenshots    = "https://bitbucket.org/repo/46g5gL/images/3807516826-Simulator%20Screen%20Shot%2022%20Jan%202016%2015.26.27.png"
  s.license          = 'MIT'
  s.author           = { "Pocket Media Tech Team" => "techteam@pocketmedia.mobi" }
  s.source           = { :git => "https://github.com/Pocketbrain/nativeadslib-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/PocketMediaBV'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'PocketMediaNativeAds/**/*.{swift, .h}'
  s.resources = 'PocketMediaNativeAds/Assets/*'

  #s.public_header_files = 'PocketMediaNativeAds/*.h'
  s.frameworks = 'UIKit'
end
