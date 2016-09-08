# PocketMediaNativeAds
[![Build Status](https://travis-ci.org/Pocketbrain/nativeadslib-ios.svg?branch=feature%2Fnew-structure-tests)](https://travis-ci.org/Pocketbrain/nativeadslib-ios)
[![codecov](https://codecov.io/gh/Pocketbrain/nativeadslib-ios/branch/feature%2Fnew-structure-tests/graph/badge.svg)](https://codecov.io/gh/Pocketbrain/nativeadslib-ios)
[![Gitter](https://badges.gitter.im/join_chat.svg)](https://gitter.im/Pocketbrain)
[![CocoaPods](https://img.shields.io/cocoapods/at/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![Version](https://img.shields.io/cocoapods/v/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![License](https://img.shields.io/cocoapods/l/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)
[![Platform](https://img.shields.io/cocoapods/p/PocketMediaNativeAds.svg?maxAge=2592000&style=flat)](http://cocoapods.org/pods/PocketMediaNativeAds)

## What are Native Ads?

Native Ads are a new way of integrating the ads within the content. While traditional advertising creates a pause to display the ads (Interstitial ads, banners, etc.), which are more or less intrusive for the user experience - native ads want to get integrated with the user flow and the way he is consuming the content. 

We offer you the ads in a structured format so you can display them as you prefer, integrated in form and functionality with your app.

We offer some standard ad units, but they will work much better if you customize them to be integrated with your app style. Your users will appreciate it, and your application will keep the style that you wanted it to have.

## Requirements

In order to use the library and have monetization tracking you need to get an advertiser token from Pocket Media. You can get it online, at [our sign up page](http://nativeads.pocketmedia.mobi/signup.html):

[![LandingPage 2016-02-15 10-19-32.png](https://bitbucket.org/repo/46g5gL/images/3248517185-LandingPage%202016-02-15%2010-19-32.png)](http://nativeads.pocketmedia.mobi/signup.html)


## Building the demo

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The project is developed in Swift but contains bridging headers to also work with Objective-C.


## Installation

PocketMediaNativeAds is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PocketMediaNativeAds"
```

## Usage
There are several ways to implement the native ads in your application. Firstly there is the AdStream which will take care of the integration for you. For Maximum customizability however there is always the option to manually integrate the NativeAds.

For both methods the parameters used are:

- placement token, to be generated in the [user dashboard](http://third-party.pmgbrain.com/)
- delegate, to receive the even callbacks as the ads are ready



### AdStream
The Adstream easily places native ads in your UITableView or UICollectionView.
You can specifiy the positions in various ways by giving an Array with fixed positions or by frequency.
Simply add the following code in your UIViewController and your ads will be automatically loaded into your view. 



#### AdStream - AdFrequency
```swift
	 var stream = NativeAdStream(controller: self, mainView: self.tableView, adMargin: 1, firstAdPosition: 1)
     stream!.requestAds("PLACEMENT_TOKEN", limit: 10) /* replace with your own token!! */
```

#### AdStream - Fixed positions
```swift
	 var adPos = [5, 2, 4]
    var stream = NativeAdStream(controller: self, mainView: self.collectionView, adsPositions: adPos)
    stream.requestAds("PLACEMENT_TOKEN", limit: 10) /* replace with your own token!! */
```

There is also the option to pass a custom XIB this has to be or a subclass of the corrosponding AbstractAdUnit for example ```AbstractAdUnitTableViewCell```. 
Dont forget to link up the outlets to your xib!


### Manual Integration
For Manual Integration the Core classes in the Pod Contain everything you need. 
To make a simple request let your designated class implement the ```NativeAdsConnectionDelegate``` like you're used to with any other IOS delegate. Then start the request, with code fragment below shows an example how to. 

```swift
        let adRequest = NativeAdsRequest(adPlacementToken: "PLACEMENT_TOKEN", delegate: self) /* replace with your own token!! */
        adRequest.debugModeEnabled = true
        adRequest.retrieveAds(5)
    
```

## App Transport Security

**Important:** the server to download the ads is ```http://offerwall.12trackway.com```. This is not *yet* under https, so you will need to add certain values to your plist, to indicate App Transport Security. 

![Info.plist â€” Edited 2016-02-21 18-14-09.png](https://bitbucket.org/repo/46g5gL/images/2846838342-Info.plist%20%E2%80%94%20Edited%202016-02-21%2018-14-09.png)

In the future all the content will be downloaded through https, following Apple recommendations.


### Receiving the results
After the request is started, the library will notify of the changes in it trough a delegate that implements the ```NativeAdsConnectionDelegate``` protocol.

This protocol has three methods:

- ```didRecieveError```: compulsory method, to be invoked in case there is an error retrieving the ads. This can happen due to network conditions, some systems error, parsing error...
- ```didRecieveResults```: when the library gets the JSON, parses it and delivers to your app, you will be notified with an Array of the NativeAd objects retrieved.
- ```didUpdateNativeAd```: not required method. In case some of the ads is modified after it has been delivered, your class will be notified trough this method.

### Displaying the ads

This is the procotol method invoked when the ads are available. In our example, we add the ads to our datasource and display it:

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

One of the possible moments when the ads might create a bad experience for the users is in the moment of the click. As we have to notify the different partners that provide the ads about the click, to be able to know that the users come from your app, we need to follow some tracking link redirections. 

In order to avoid that bad experience, we provide you the ```openAdUrl``` method in the ```NativeAd``` class. The method receives the parent view as an argument, and it will create a UIWebView inside of your app, where the links will be followed.

```swift
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let ad = itemsTable[indexPath.row] as? NativeAd{
            print("Opening url: \(ad.clickURL.absoluteString)")
            // This method will take of opening the ad inside of the app, until we have an iTunes url
            ad.openAdUrl(self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
```

Alternatively you can use ```openAdUrlInForeground()``` to open the URL directly in the browser - but the user experience will be much worse.


## Look and feel

The look of the ads is totally customisable, that's the main objective of the project. One of the easiest ad units to adapt would be the in-feed native ads, but you can use the data we provide you in any way, as long as you don't trick the users and don't force them to click your ads.

![Simulator Screen Shot 22 Jan 2016 15.26.27.png](https://bitbucket.org/repo/46g5gL/images/3807516826-Simulator%20Screen%20Shot%2022%20Jan%202016%2015.26.27.png)

## Author

Pocket Media Tech Team, [support@pocketmedia.mobi](mailto:support@pocketmedia.mobi). Feel free to contact us for any suggestion improvements you might have. 

We work for you, we want you to be able to implement the ads in 5 minutes and start monetizing your audience with a totally native and tailored experience! Tell us what you are missing, what else you need our library to make for you - and it will happen.

## License

PocketMediaNativeAds is available under the MIT license. See the LICENSE file for more info.
