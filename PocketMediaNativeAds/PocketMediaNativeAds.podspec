#
# Be sure to run `pod lib lint PocketMediaNativeAds.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PocketMediaNativeAds"
  s.version          = "0.0.1"
  s.summary          = "PocketMediaNativeAds allows you to integrate Native Ads in your app quickly."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
With PocketMediaNativeAds you can quickstart the process of adding native ads to your iOS project.
Everything is customizable, but this library allows you to testdrive the implementation real fast.
                       DESC

s.homepage         = "http://pocketmedia.mobi"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Pocket Media Tech Team" => "techteam@pocketmedia.mobi" }
  s.source           = { :git => "https://bitbucket.org/pocketbrain/nativeadslib-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/PocketMediaBV'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PocketMediaNativeAds' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
