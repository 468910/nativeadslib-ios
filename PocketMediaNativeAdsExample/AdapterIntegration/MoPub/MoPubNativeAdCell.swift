import UIKit
import MoPub

/**
 Example of a default MoPub integration. No direct reference to PocketMedia, but will fill up ads from PocketMedia.
 This config is all done in the MoPub web dashboard. In other words, if you've implemented MoPub you can make use of PocketMedia's ads.
 */
class MoPubNativeAdCell: UITableViewCell, MPNativeAdRendering {

    // MARK: Properties

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var mainTextLabel: UILabel!

    @IBOutlet weak var callToActionLabel: UILabel!

    @IBOutlet weak var mainImageView: UIImageView!

    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var privacyInformationIconImageView: UIImageView!

    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
    }

    // MARK: MPNativeAdRendering

    func nativeMainTextLabel() -> UILabel! {
        return self.mainTextLabel
    }

    func nativeTitleTextLabel() -> UILabel! {
        return self.titleLabel
    }

    func nativeCallToActionTextLabel() -> UILabel! {
        return self.callToActionLabel
    }

    func nativeIconImageView() -> UIImageView! {
        return self.iconImageView
    }

    func nativeMainImageView() -> UIImageView! {
        return self.mainImageView
    }

    func nativeVideoView() -> UIView! {
        return self.videoView
    }

    func nativePrivacyInformationIconImageView() -> UIImageView! {
        return self.privacyInformationIconImageView
    }

    // Return the nib used for the native ad.
    class func nibForAd() -> UINib! {
        return UINib(nibName: "MoPubNativeAdCell", bundle: nil)
    }
}
