class HLHotelDetailsCommonCellFactory: HLHotelDetailsCellFactory {

    class func createRatingDetailItemsWithTrustYouData(_ trustyou: HDKTrustyou, cellWidth: CGFloat) -> [TableItem] {
        guard trustyou.sentiments.count > 0 else { return [] }

        let flattenRatingItems = ratingItems(fromSentiments: trustyou.sentiments, trustyou: trustyou, limit: trustyou.sentiments.count)
        return HLTwoColumnCellsDataSource(flattenedItems: flattenRatingItems, cellWidth: cellWidth, canFillHalfScreen: HLHotelDetailsRatingDetailsCell.canFillHalfScreen).splitItemsRespectOrder()
    }

    class func createShortRatingDetails(withTrustYou trustyou: HDKTrustyou, moreHandler: (() -> Void)?, cellWidth: CGFloat) -> [TableItem] {
        guard trustyou.sentiments.count > 4 else {
            return createRatingDetailItemsWithTrustYouData(trustyou, cellWidth: cellWidth)
        }

        let shownItems = 3
        var items: [NamedHotelDetailsItem] = ratingItems(fromSentiments: trustyou.sentiments, trustyou: trustyou, limit: shownItems)
        items.append(MoreRatingDetailsItem(moreCount: trustyou.sentiments.count - shownItems, moreHandler: moreHandler))
        return HLTwoColumnCellsDataSource(flattenedItems: items, cellWidth: cellWidth, canFillHalfScreen: HLHotelDetailsRatingDetailsCell.canFillHalfScreen).splitItemsRespectOrder()
    }

    private class func ratingItems(fromSentiments sentiments: [HDKSentimentScore], trustyou: HDKTrustyou, limit: Int) -> [RatingItem] {
        var ratingItems = [RatingItem]()
        for i in 0..<limit {
            let sentiment = sentiments[i]
            ratingItems.append(RatingDetailItem.init(name: sentiment.name, trustYou: trustyou, score: sentiment.score))
        }

        return ratingItems
    }

    class func features(_ variant: HLResultVariant, badges: [HLPopularHotelBadge]?) -> [FeatureItem] {
        let hotel = variant.hotel
        var features: [FeatureItem] = []

        if let hotelName = hotel.name, !hotelName.isEmpty {
            let hotelNameItem = MultipleLinesFeatureItem(name: hotelName, image: UIImage(named: "hotelPropertyType")!)
            features.append(hotelNameItem)
        }

        let roomsCount = StringUtils.propertyTypeAndRoomsCount(hotel: hotel)
        if !roomsCount.isEmpty {
            let roomsCountItem = FeatureItem(name: roomsCount, image: UIImage(named: "roomsCount")!)
            features.append(roomsCountItem)
        }

        if hotel.yearOpened > 0 {
            let title = String(format: NSLS("HOTEL_DETAIL_YEAR_OPENED"), hotel.yearOpened.description)
            let yearOpenedItem = FeatureItem(name: title, image: UIImage(named: "hotelOpenedIcon")!)
            features.append(yearOpenedItem)
        }

        if hotel.yearRenovated > 0 {
            let title = String(format: NSLS("HOTEL_DETAIL_YEAR_RENOVATED"), hotel.yearRenovated.description)
            let yearRenovatedItem = FeatureItem(name: title, image: UIImage(named: "hotelRenovatedIcon")!)
            features.append(yearRenovatedItem)
        }

        if let freeParkingFeature = findFreeParking(hotel) {
            features.append(freeParkingFeature)
        }

        if let staffLanguagesItem = staffLanguages(hotel) {
            features.append(staffLanguagesItem)
        }

        if let badges = badges?.filter({ $0 is HLTextBadge || $0 is HLIconBadge }), badges.count > 0 {
            let feature = FeatureItem(name: "", image: UIImage(named: "badgeIcon")!, badges: badges)
            features.append(feature)
        }

        return features
    }

    class func accommodationItems(_ variant: HLResultVariant, startDate: Date?, endDate: Date?, containerWidth: CGFloat) -> [AccommodationItem] {

        let hotel = variant.hotel
        var items: [AccommodationItem] = []

        if HotelPropertyTypeUtils.hotelPropertyTypeEnum(hotel) != .unknown {

            let kidsCount = variant.searchInfo.kidAgesArray.count
            let adultsCount = variant.searchInfo.adultsCount
            let guestsString = StringUtils.guestsDescription(withAdultsCount: adultsCount, kidsCount: kidsCount)

            let guestsItem = AccommodationItem(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_GUESTS"), text: guestsString)
            items.append(guestsItem)
        }

        if let checkinDate = startDate, let checkinTime = hotel.checkInTime {
            let checkinDateAndTime = DateUtil.setTimeFor(checkinDate, time: checkinTime)!

            let title = NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKIN")

            let longText = StringUtils.longCheck(inDateAndTime: checkinDateAndTime)
            let shortText = StringUtils.shortCheck(inDateAndTime: checkinDateAndTime)
            let text = AccommodationCell.canFill(title, text: longText, cellWidth: containerWidth)
                ? longText
                : shortText

            let checkinItem = AccommodationItem(name: title, text: text)
            items.append(checkinItem)
        }

        if let checkoutDate = endDate, let checkoutTime = hotel.checkOutTime {
            let checkoutDateAndTime = DateUtil.setTimeFor(checkoutDate, time: checkoutTime)

            let title = NSLS("HL_HOTEL_DETAIL_INFORMATION_CHECKOUT")

            let longText = StringUtils.longCheckOutDateAndTime(checkoutDateAndTime!)
            let shortText = StringUtils.shortCheckOutDateAndTime(checkoutDateAndTime!)
            let text = AccommodationCell.canFill(title, text: longText, cellWidth: containerWidth)
                ? longText
                : shortText

            let checkoutItem = AccommodationItem(name: title, text: text)
            items.append(checkoutItem)
        }

        let amenities = hotel.roomAmenities() + hotel.hotelAmenities()
        items = addAmenityItems(from: amenities, items:items)
        TableItem.setFirstAndLast(items: items)

        return items
    }

    private class func addAmenityItems(from amenities: [HDKAmenity], items: [AccommodationItem]) -> [AccommodationItem] {
        var result = items
        for amenity in amenities {
            if amenity.slug == AmenityConst.cleaningKey {
                if amenity.isPaid {
                    let cleaningItem = AccommodationItem(name: NSLS("HL_HOTEL_DETAIL_AMENITY_CLEANING"), text: amenity.price)
                    cleaningItem.shouldHighlightText = true
                    result.append(cleaningItem)
                }
            }
            if amenity.slug == AmenityConst.depositKey {
                let price = amenity.isPriceUnknown ? NSLS("HL_HOTEL_DETAIL_PAID_AMENITY_UNKNOWN_PRICE") : amenity.price
                let depositItem = AccommodationItem(name: NSLS("HL_HOTEL_DETAIL_AMENITY_DEPOSIT"), text: price)
                depositItem.shouldHighlightText = true
                result.append(depositItem)
            }
        }
        return result
    }

    private class func findFreeParking(_ hotel: HDKHotel) -> FeatureItem? {
        let hotelAmenities = hotel.hotelAmenities()
        guard hotelAmenities.count > 0 else { return nil }

        for i in 0..<hotelAmenities.count {
            let amenity = hotelAmenities[i]
            let key = amenity.slug
            guard key == "parking" else { continue }

            if amenity.isFree {
                let parkingTitle = NSLS("HL_HOTEL_DETAIL_FEATURES_FREE_PARKING_TITLE")
                return FeatureItem(name: parkingTitle, image: UIImage(named: "parkingIcon")!)
            }
        }
        return nil
    }

    fileprivate class func staffLanguages(_ hotel: HDKHotel) -> FeatureItem? {
        let langList = hotel.staffLanguages().map { $0.name.lowercased() }

        guard langList.count > 0 else { return nil }
        guard let text = StringUtils.staffLanguages(languages: langList) else { return nil }

        return MultipleLinesFeatureItem(name: text, image: UIImage(named: "guestsLanguageSplitIcon")!)
    }

    class func featureCell(_ feature: FeatureItem, tableView: UITableView, indexPath: IndexPath, first: Bool, last: Bool) -> UITableViewCell {
        let cell: HLTableViewCell

        if feature.badges.count > 0 {
            let c = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsBadgesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsBadgesCell
            c.iconView.image = feature.image
            c.badges = feature.badges
            cell = c
        } else {
            let c = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsFeaturesCell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsFeaturesCell
            c.titleLabel.text = feature.name
            c.iconView.image = feature.image
            c.descriptionLabel.text = feature.descriptionString
            c.columnCellStyle = .oneColumn
            cell = c
        }

        cell.first = first
        cell.last = last

        return cell
    }
}
