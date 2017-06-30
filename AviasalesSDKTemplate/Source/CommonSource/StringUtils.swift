extension StringUtils {

    static func propertyTypeAndRoomsCount(hotel: HDKHotel) -> String {

        let propertyType = HotelPropertyTypeUtils.hotelPropertyTypeEnum(hotel)
        let propertyTypeString = propertyType != .unknown
            ? HotelPropertyTypeUtils.localizedHotelPropertyType(hotel)
            : nil

        var roomsCountString: String? = nil
        if hotel.roomsCount > 0 {
            roomsCountString = String(format: NSLSP("HOTEL_DETAIL_ROOMS_COUNT", Float(hotel.roomsCount)), hotel.roomsCount.description)
        }

        return [propertyTypeString, roomsCountString].flatMap { $0 }.joined(separator: ", ")
    }

    static func staffLanguages(languages: [String]) -> String? {
        guard languages.count > 0 else { return nil }

        let languagesString = languages.joined(separator: ", ")
        let formatString = NSLSP("HL_HOTEL_DETAIL_STAFF_LANGUAGES", Float(languages.count))
        return String(format: formatString, arguments: [languagesString])
    }

    static func attributedRangeValueText(currency: HDKCurrency,
                                         minValue: Float,
                                         maxValue: Float,
                                         textColor: UIColor = JRColorScheme.lightTextColor(),
                                         numberColor: UIColor = JRColorScheme.lightTextColor()) -> NSAttributedString {

        let textFont = UIFont.systemFont(ofSize: 12)
        let numberFont = UIFont.systemFont(ofSize: 12)

        let textStyle = [NSFontAttributeName: textFont,
                         NSForegroundColorAttributeName: textColor]

        let lowerStr = StringUtils.attributedPriceString(withPrice: minValue, currency:currency, font:numberFont)
        let upperStr = StringUtils.attributedPriceString(withPrice: maxValue, currency:currency, font:numberFont)

        let str = String(format: NSLS("HL_LOC_FILTER_RANGE"), "lowerValue", "upperValue")
        let result = NSMutableAttributedString(string: str)
        result.addAttributes(textStyle, range: NSRange(location: 0, length: str.characters.count))

        let lowerPlaceholderRange = (result.string as NSString).range(of: "lowerValue")
        if lowerPlaceholderRange.location != NSNotFound {
            result.replaceCharacters(in: lowerPlaceholderRange, with: lowerStr)
        }

        let upperPlaceholderRange = (result.string as NSString).range(of: "upperValue")
        if upperPlaceholderRange.location != NSNotFound {
            result.replaceCharacters(in: upperPlaceholderRange, with: upperStr)
        }

        let lowerRange = (result.string as NSString).range(of: lowerStr.string)
        if lowerRange.location != NSNotFound {
            result.addAttribute(NSForegroundColorAttributeName, value: numberColor, range: lowerRange)
        }

        let upperRange = (result.string as NSString).range(of: upperStr.string, options: String.CompareOptions.backwards)
        if upperRange.location != NSNotFound {
            result.addAttribute(NSForegroundColorAttributeName, value: numberColor, range: upperRange)
        }

        return result
    }

    // MARK: - Rating

    static func attributedRatingString(for rating: Int,
                                       textColor: UIColor = JRColorScheme.lightTextColor(),
                                       numberColor: UIColor = JRColorScheme.lightTextColor()) -> NSAttributedString {

        let textStyle = [NSForegroundColorAttributeName: textColor,
                         NSFontAttributeName: UIFont.systemFont(ofSize: 12)]

        let numberStyle = [NSForegroundColorAttributeName: numberColor,
                           NSFontAttributeName: UIFont.systemFont(ofSize: 12)]

        let textString = NSLS("HL_LOC_FILTER_FROM_STRING") + " "
        let numberString = shortRatingString(rating)

        let textAttrString = NSAttributedString(string: textString, attributes: textStyle)
        let numberAttrString = NSAttributedString(string: numberString, attributes: numberStyle)

        let result = NSMutableAttributedString(attributedString: textAttrString)
        result.append(numberAttrString)

        return result
    }

    static func reviewsCountDescription(with reviewsCount: Int) -> String {
        if reviewsCount > 0 {
            let countStr = StringUtils.formattedNumberString(withNumber: reviewsCount)
            let title = NSLSP("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_BASED", Float(reviewsCount))

            return String(format: title, countStr)
        } else {
            return NSLS("HL_NO_HOTEL_REVIEWS")
        }
    }

    static func ratingHotelDescription(with reviewsCount: Int) -> String {
        if reviewsCount > 0 {
            let countStr = StringUtils.formattedNumberString(withNumber: reviewsCount)
            var title = NSLSP("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_BASED", Float(reviewsCount))
            title = String(format: "(%@)", title)

            return String(format: title, countStr)
        } else {
            return NSLS("HL_HOTEL_REVIEWS")
        }
    }

    static func reviewDate(date: Date) -> String {
        let formatter = HDKDateUtil.standardFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    static func offersString(withCount count: Int?) -> String {
        guard let count = count else { return "" }

        let countString = NSLSP("HL_HOTEL_DETAIL_OFFERS_COUNT", Float(count))
        return String(format: countString, count)
    }

    static func ratingAttributedString(rating: Int, full: Bool) -> NSAttributedString {
        guard rating > 0 else { return NSAttributedString() }

        let ratingNumbers = shortRatingString(forRating: rating)
        let boldAttr = [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor.white]
        let attributedText = NSMutableAttributedString(string: ratingNumbers, attributes: boldAttr)
        if full {
            let lightAttr = [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.white]
            let attributedRatingText = NSAttributedString(string: ratingText(forRating: rating), attributes: lightAttr)
            attributedText.append(attributedRatingText)
            attributedText.addAttribute(NSKernAttributeName, value: 5, range: NSRange(location: ratingNumbers.characters.count - 1, length: 1))
        }

        return attributedText
    }

    static func shortRatingString(forRating rating: Int, locale: Locale = Locale.current) -> String {
        if rating == 0 || rating == 100 {
            return String(rating / 10)
        } else {
            return String.init(format: "%.1f", Double(rating) / 10.0)
        }
    }

    static func ratingText(forRating rating: Int) -> String {
        if rating > 95 {
            return NSLS("HOTEL_RATING_EXCEPTIONAL")
        } else if rating > 89 {
            return NSLS("HOTEL_RATING_WONDERFUL")
        } else if rating > 85 {
            return NSLS("HOTEL_RATING_EXCELLENT")
        } else if rating > 79 {
            return NSLS("HOTEL_RATING_VERY_GOOD")
        } else if rating > 69 {
            return NSLS("HOTEL_RATING_GOOD")
        } else {
            return NSLS("HOTEL_RATING_FAIR")
        }
    }
}
