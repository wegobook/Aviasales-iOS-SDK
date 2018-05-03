//
//  UIImage+HLImages.swift
//  HotelLook
//
//  Created by tromg on 19.11.15.
//  Copyright © 2015 Anton Chebotov. All rights reserved.
//

import Foundation

@objc extension UIImage {

    class var photoPlaceholder: UIImage {
        return UIImage(named: "hotelPhotoPlaceholder") ?? UIImage()
    }

    // MARK: - Stars

    class var yellowStar: UIImage {
        return UIImage(named: "yellowStar") ?? UIImage()
    }

    class var yellowStarEmpty: UIImage {
        return UIImage(named: "yellowStarEmpty") ?? UIImage()
    }

    class var whiteStar: UIImage {
        return UIImage(named: "whiteStar") ?? UIImage()
    }

    class var whiteStarEmpty: UIImage {
        return UIImage(named: "whiteStarEmpty") ?? UIImage()
    }

    class var smallWhiteStar: UIImage {
        return UIImage(named: "smallWhiteStar") ?? UIImage()
    }

    class var smallWhiteStarEmpty: UIImage {
        return UIImage(named: "smallWhiteStarEmpty") ?? UIImage()
    }

    // MARK: - Trustyou legend Images

    class var trustyouLegendGreenImage: UIImage {
        return UIImage(named: "trustyouLegendGreenImage") ?? UIImage()
    }

    class var trustyouLegendYellowImage: UIImage {
        return UIImage(named: "trustyouLegendYellowImage") ?? UIImage()
    }

    class var trustyouLegendRedImage: UIImage {
        return UIImage(named: "trustyouLegendRedImage") ?? UIImage()
    }

    class var peekCheckImage: UIImage {
        return UIImage(named: "peekCheck") ?? UIImage()
    }

    class var peekCheckWarningImage: UIImage {
        return UIImage(named: "peekCheckWarning") ?? UIImage()
    }

    class var peekCheckMissImage: UIImage {
        return UIImage(named: "peekCheckMiss") ?? UIImage()
    }

    class var toastHeartIconImage: UIImage {
        return UIImage(named: "toastHeartIcon") ?? UIImage()
    }

    class var toastCheckMarkIcon: UIImage {
        return UIImage(named: "toastCheckMarkIcon") ?? UIImage()
    }

    class func fixedImageByScore(_ score: Int) -> UIImage {
        let image: UIImage
        if score < 65 {
            image = UIImage.trustyouLegendRedImage
        } else if score >= 65 && score <= 75 {
            image = UIImage.trustyouLegendYellowImage
        } else {
            image = UIImage.trustyouLegendGreenImage
        }

        return image
    }
}
