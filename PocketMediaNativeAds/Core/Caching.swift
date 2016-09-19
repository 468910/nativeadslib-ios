//
//  Caching.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 16/09/16.
//
//

import Foundation
import UIKit

class Caching {

    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "PocketMediaCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()

}

extension NSURL {

    typealias ImageCacheCompletion = UIImage -> Void

    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        return Caching.sharedCache.objectForKey(
            absoluteString) as? UIImage
    }

    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: ImageCacheCompletion) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(self) {
            data, response, error in
            if error == nil {
                if let  data = data,
                    image = UIImage(data: data) {
                    Caching.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString,
                        cost: data.length)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }

}

extension UIImageView {
    func setImageFromURL(url: NSURL) {
        self.image = UIImage()
        if let campaignImage = url.cachedImage {
            //Cached
            dispatch_async(dispatch_get_main_queue(), {
                self.image = campaignImage
                self.alpha = 1
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                // Not cached, so load then fade it in.
                self.alpha = 0
            })
            url.fetchImage { downloadedImage in
                // Check the cell hasn't recycled while loading.
                if url == downloadedImage {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.image = downloadedImage
                        self.reloadInputViews()
                    })
                    UIView.animateWithDuration(0.3) {
                        self.alpha = 1
                    }
                }
            }
        }
    }
}
