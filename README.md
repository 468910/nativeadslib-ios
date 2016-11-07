# PocketMedia: iOS NativeAds library
[![Code Climate](https://codeclimate.com/github/Pocketbrain/nativeadslib-ios/badges/gpa.svg)](https://codeclimate.com/github/Pocketbrain/nativeadslib-ios)
[![Build Status](https://travis-ci.org/Pocketbrain/nativeadslib-ios.svg?branch=master)](https://travis-ci.org/Pocketbrain/nativeadslib-ios)
[![Build Status](https://www.bitrise.io/app/b7a8ab5efda24990.svg?token=n6H_COg_cUKeKnUEWEMJTw&branch=master)](https://www.bitrise.io/app/b7a8ab5efda24990)
[![codecov](https://codecov.io/gh/Pocketbrain/nativeadslib-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/Pocketbrain/nativeadslib-ios)
[![Gitter](https://badges.gitter.im/join_chat.svg)](https://gitter.im/Pocketbrain)
[![CocoaPods](https://img.shields.io/cocoapods/at/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![Version](https://img.shields.io/cocoapods/v/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![License](https://img.shields.io/cocoapods/l/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![Platform](https://img.shields.io/cocoapods/p/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)

This open-source (Swift/Objective-c) library allows developers to easily show ads provided by PocketMedia natively in their apps. While the traditional way of advertising in mobile applications usually involves a disruption in natural user-flow to show the ad (Interstitial ads, banners, etc.) this native solution allows the ads to be integrated in the context where they will be displayed. That in turn makes it less intrusive for the user experience.

The library comes with standard ad units (ways of displaying the ad). You are encouraged to extend/copy these into project and and customize them to your liking, specially to match your application look and feel. This method is called using the adStream - and requires just a few lines of code to start using it.

The alternative solution is using the library to just do the network calls and use the NativeAd (Class) model. Using these core functionalities, you are able to write your own custom ad units and manipulate them in any way that fits your app. This method is called manual integration.

## Requirements

In order to use the library and have monetization tracking you need to get an advertiser token from Pocket Media. You can get it online, at [our sign up page](http://nativeads.pocketmedia.mobi/signup.html):

[![LandingPage 2016-02-15 10-19-32.png](https://bitbucket.org/repo/46g5gL/images/3248517185-LandingPage%202016-02-15%2010-19-32.png)](http://nativeads.pocketmedia.mobi/signup.html)

## Building the demo

To run the example project, clone the repo, and run `pod install` then open the workspace and run the example scheme.

The project is developed in Swift but contains bridging headers to also work with Objective-C.

## Installation

PocketMediaNativeAds is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PocketMediaNativeAds"
```

Then run the following in your terminal:
```ruby
pod install
```

### Troubleshooting
#### Problems with doing a pod install.
Try the following:
- gem install bundler
- cd into the project files
- bundle install
Now try it again.

## Usage
There are several ways to implement the native ads in your application. Firstly, there is the AdStream which will take care of the integration for you. For maximum customizability however there is always the option to manually integrate the NativeAds.

For both methods the parameters used are:

- placement token, to be generated in the [user dashboard](http://third-party.pmgbrain.com/)
- delegate, to receive the event callbacks as the ads are ready

[Docs](https://htmlpreview.github.io/?https://github.com/Pocketbrain/nativeadslib-ios/feature/new-structure-tests/docs/index.html)

### AdStream
The Adstream allows to easily show native ads in your UITableView and or UICollectionView.
You can specify the positions by giving an Array with fixed positions or frequency. Simply add the following code in your UIViewController and your ads will be automatically loaded into your view.

#### AdStream - Ad margin
```swift
    stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", adPosition: MarginAdPosition(margin: 2, adPositionOffset: 0)) /* replace with your own token!! */
    stream?.requestAds(10)//Add 5 ads
```

#### AdStream - Fixed positions
```swift
    stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", adPosition: PredefinedAdPosition(positions: [1, 3, 8], adPositionOffset: 0)) /* replace with your own token!! */
    stream?.requestAds(10)//Add 5 ads
```

There is also the option to pass a custom XIB this has to be or a subclass of the corresponding  AbstractAdUnit for example ```AbstractAdUnitTableViewCell```.
Dont forget to link up the outlets to your xib!

### Manual Integration
You could also opt for just using the library to do the network request and manually integrate the ads. To do so create a new delegate class that implements ```NativeAdsConnectionDelegate``` and call NativeAdsRequest to initiate an ad request call.

```swift
    let adRequest = NativeAdsRequest(adPlacementToken: "PLACEMENT_TOKEN", delegate: self) /* replace with your own token!! */
    adRequest.retrieveAds(5)//The amount of ads you want to receive.
```

## App Transport Security

**Important:** the server to download the ads is ```http://offerwall.12trackway.com```. This is not *yet* under https, so you will need to add certain values to your plist, to indicate App Transport Security.

![Info.plist â€” Edited 2016-02-21 18-14-09.png](https://bitbucket.org/repo/46g5gL/images/2846838342-Info.plist%20%E2%80%94%20Edited%202016-02-21%2018-14-09.png)

In the future this will change to https, following Apple recommendations.

### Receiving the results
After the request has started requesting adds it will call the following three methods to notify the delegate class (the host application) of the ad status:

- ```didRecieveError```: compulsory method, to be invoked in case there is an error retrieving the ads. This can happen due to network conditions, some systems error, parsing error...
- ```didRecieveResults```: when the library gets the JSON, parses it and delivers to your app, you will be notified with an Array of the NativeAd objects retrieved.
- ```didUpdateNativeAd```: not required method. In case some of the ads is modified after it has been delivered, your class will be notified trough this method.

### Displaying the ads
This is the protocol method invoked when the ads are available. In our example, we add the ads to our datasource and display it:
```swift
    func didRecieveResults(nativeAds: [NativeAd]){
        self.nativeAds = nativeAds
        if itemsTable.count > 0 {
            for ad in nativeAds {
                itemsTable.insert(ad, atIndex: Int(arc4random_uniform(UInt32(itemsTable.count))))
            }
            tableView.reloadData()
        }
    }
```

Together with the method were the table cell is displayed:
```swift

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch itemsTable[indexPath.row] {
        case let item as ItemTableView :
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath:indexPath) as! ItemCell
            cell.name.text = item.title
            cell.descriptionItem.text = item.descriptionItem
            loadImageAsynchronouslyFromUrl(item.imageURL, imageView: cell.artworkImageView)
            return cell
        case let ad as NativeAd :
            let cell = tableView.dequeueReusableCellWithIdentifier("AdCell", forIndexPath:indexPath) as! AdCell
            cell.campaignNameLabel.text = ad.campaignName
            cell.campaignDescriptionLabel.text = ad.campaignDescription

            if(ad.campaignImage != nil){
            loadImageAsynchronouslyFromUrl(ad.campaignImage, imageView: cell.campaignImageView)
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
```

### Opening the URL
When a user clicks on one of the ads it will open a third party link. In other ad solutions this usually creates a bad experience for the user. However this library comes with a solution to circumvent this experience and avoid the user clicking away. Each NativeAd instance comes with a method called ```openAdUrl``` which using the FullScreenBrowser opener creates a smooth transition to the publisher.

```swift
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ad = itemsTable[indexPath.row] as? NativeAd{
            print("Opening url: \(ad.clickURL.absoluteString)")
            // This method will take of opening the ad inside of the app, until we have an iTunes url
            ad.openAdUrl(FullscreenBrowser(parentViewController: self))
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
```

Alternatively you can use ```openAdUrlInForeground()``` to open the URL directly in the browser.

## Look and feel

One of the main objectives of these project is creating a easy to use library that allowes the ads to be totally customisable. An example of this is the Adstream UITableView example. All you have to provide is an existing UITableView and the placement token and you are good to go!

![Simulator Screen Shot 22 Jan 2016 15.26.27.png](https://bitbucket.org/repo/46g5gL/images/3807516826-Simulator%20Screen%20Shot%2022%20Jan%202016%2015.26.27.png)

## Author

Pocket Media Tech Team, [support@pocketmedia.mobi](mailto:support@pocketmedia.mobi). Feel free to contact us for any suggestion improvements you might have.

We work for you, we want you to be able to implement the ads in 5 minutes and start monetizing your audience with a totally native and tailored experience! Tell us what you are missing, what else you need our library to make for you - and it will happen.

## License

PocketMediaNativeAds is available under the MIT license. See the LICENSE file for more info.
