Pocket Media Native Ads iOS library Changelog

* 1.0.0: Swift 3.0 compatibility.
* 0.4.2: ATS Compatibility, connecting by default to HTTPs encrypted endpoints.
* 0.4.1: Improved objective-c compatibility of the library.
* 0.4.0: Improved performance and stability. Code quality improved. Code is now covered by unit tests. For upgrade process check [upgrade documentation](UPGRADE.md)
* 0.3.0: Implemented ```AdStream``` for the simplest implementation of ads in UITableViews and CollectionViews.
* 0.2.2: implemented Quality Service - to improve the user experience while opening the ads.
* 0.2.1: removed app token, replaced by ad placement token.
* 0.2.0: renamed classes and re-structured internal code to make it cleaner.
  changes required in code:
  * ```NativeAdsConnectionProtocol``` renamed to ```NativeAdsConnectionDelegate```
  * ```NativeAd.openCampaign``` has been renamed to ```NativeAd.openAdUrl``` to make its purpouse more clear.
* 0.1.8: solved an issue when the user had the option to limit Advertising Tracking enabled.
* 0.1.7: improved the handling of the post-install even in ViewControllers without UINavigationController.
* 0.1.6: improved compatibility with ViewControllers without UINavigationController.
* 0.1.5: improved Objective-C compatibility by exposing more methods trough ```@objc```.
* 0.1.4: bugfixing and validity checking of the JSON received. 
* 0.1.3: code cleanup.
* 0.1.2: added screenshots to readme file.
* 0.1.1: code reorganization.
* 0.1.0: initial release of the preview functionalities.
