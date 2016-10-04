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
            absoluteString!) as? UIImage
    }

    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: ImageCacheCompletion) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(self) {
            data, response, error in
            if error == nil {
                if let data = data,
                    image = UIImage(data: data) {
                    Caching.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString!,
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

public extension UIImageView {
    func nativeSetImageFromURL(url: NSURL) {
        //self.image = drawCustomImage(CGSize(width: 100, height: 100))
        if let campaignImage = url.cachedImage {
            //Cached
            dispatch_async(dispatch_get_main_queue()) {
                self.image = campaignImage
            }
        } else {
            url.fetchImage { downloadedImage in
                // Check the cell hasn't recycled while loading.
                UIView.transitionWithView(self, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    self.image = downloadedImage
                }, completion: nil)
            }
        }
    }
}
