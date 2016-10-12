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
    static let sharedCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "PocketMediaCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()
}

extension URL {

    typealias ImageCacheCompletion = (UIImage) -> Void

    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        
        
//        Caching.sharedCache
        
        return Caching.sharedCache.object(
            forKey: absoluteString as NSString)
    }

    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(_ completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: self, completionHandler: {
            data, response, error in
            if error == nil {
                if let data = data,
                    let image = UIImage(data: data) {
                    Caching.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString as NSString,
                        cost: data.count)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }) 
        task.resume()
    }

}

public extension UIImageView {
    func nativeSetImageFromURL(_ url: URL) {
        //self.image = drawCustomImage(CGSize(width: 100, height: 100))
        if let campaignImage = url.cachedImage {
            //Cached
            DispatchQueue.main.async {
                self.image = campaignImage
            }
        } else {
            url.fetchImage { downloadedImage in
                // Check the cell hasn't recycled while loading.
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.image = downloadedImage
                }, completion: nil)
            }
        }
    }
}
