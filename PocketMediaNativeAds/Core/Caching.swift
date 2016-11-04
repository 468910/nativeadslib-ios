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
//		cache.countLimit = 1000 // Max 20 images in memory.
//		cache.totalCostLimit = 100 * 1024 * 1024 // Max 100MB used.
		return cache
	}()
}

extension NSURL {

	typealias ImageCacheCompletion = UIImage -> Void

    private static var callbacks = [String : [ImageCacheCompletion] ]()

    func getCacheKey() -> String {
        return self.absoluteString!//self.lastPathComponent!
    }

	/// Retrieves a pre-cached image, or nil if it isn't cached.
	/// You should call this before calling fetchImage.
	var cachedImage: UIImage? {
        return Caching.sharedCache.objectForKey(
			getCacheKey()) as? UIImage
	}

	/// Fetches the image from the network.
	/// Stores it in the cache if successful.
	/// Only calls completion on successful image download.
	/// Completion is called on the main thread.
	func fetchImage(completion: ImageCacheCompletion) {

        if NSURL.callbacks[self.getCacheKey()] == nil {
            //create it.
            NSURL.callbacks[self.getCacheKey()] = [ImageCacheCompletion]()

            let task = NSURLSession.sharedSession().dataTaskWithURL(self) {
                data, response, error in
                if error == nil {
                    if let data = data, image = UIImage(data: data) {

                        dispatch_sync(dispatch_get_main_queue()) {
                            Caching.sharedCache.setObject(image, forKey: self.getCacheKey(), cost: data.length)

                            for callback in NSURL.callbacks[self.getCacheKey()]! {
                                callback(image)
                            }
                            //Reset it. So that if the Cache decides the remove this image. We'll be able to download it again.
                            NSURL.callbacks[self.getCacheKey()] = nil

                        }

                    }
                }
            }
            task.resume()

        }
        //Add to the list of images we need to call when we have the requested result.
        NSURL.callbacks[self.getCacheKey()]!.append(completion)
	}

}

public extension UIImageView {
    //The last url that an instance of the imageView has asked for.
    private static var currentUrl = [UIImageView : NSURL]()

	func nativeSetImageFromURL(url: NSURL) {

        if UIImageView.currentUrl[self] != url {
            self.image = UIImage()
        }

		// self.image = drawCustomImage(CGSize(width: 100, height: 100))
		if let campaignImage = url.cachedImage {
            // Cached
            self.image = campaignImage

            //Clear up after ourselves.
            UIImageView.currentUrl[self] = nil

		} else {
            //Set this url as the last url we've asked for.
            UIImageView.currentUrl[self] = url

			url.fetchImage({ downloadedImage in
                //In some cases this fetchImage call gets called very quickly if people scroll very quickly.
                //This check here, makes sure that the response we are getting for this image, is actually the one he has last requested.
                if UIImageView.currentUrl[self] != url {
                    return
                }

				// Check the cell hasn't recycled while loading.
				UIView.transitionWithView(self, duration: 0.3, options: .TransitionCrossDissolve, animations: {
					self.image = downloadedImage
                }, completion: nil)
			})
		}
	}

}
