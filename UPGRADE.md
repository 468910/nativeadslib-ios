# PocketMedia: iOS NativeAds library
##Upgrade Notice 0.4.0
- The api has changed in version 0.4.0. Both implementation strategies have been renewed (adstream and custom implementation using adRequest).

### AdStream - AdFrequency
#### Before:
```swift
     var stream = NativeAdStream(controller: self, mainView: self.tableView, adMargin: 1, firstAdPosition: 1)
     stream!.requestAds("PLACEMENT_TOKEN", limit: 10) /* replace with your own token!! */
```

#### Now:
```swift
    stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", adPosition: MarginAdPosition(margin: 2, adPositionOffset: 0)) /* replace with your own token!! */
    stream?.requestAds(10)//Add 5 ads
```


### AdStream - Fixed positions
#### Before:
```swift
     var adPos = [5, 2, 4]
    var stream = NativeAdStream(controller: self, mainView: self.collectionView, adsPositions: adPos)
    stream.requestAds("PLACEMENT_TOKEN", limit: 10) /* replace with your own token!! */
```

#### Now:
```swift
    stream = NativeAdStream(controller: self, view: self.tableView, adPlacementToken: "894d2357e086434a383a1c29868a0432958a3165", adPosition: PredefinedAdPosition(positions: [1, 3, 8], adPositionOffset: 0)) /* replace with your own token!! */
    stream?.requestAds(10)//Add 5 ads
```

### Notable changes
- Starting from 0.4.0. Users can now specify their own logic of where ads should be. Using the AdPosition protocol (interface).
- Increased performance and stability. The library now has around 80% coverage. Many bugs were indentified and removed.