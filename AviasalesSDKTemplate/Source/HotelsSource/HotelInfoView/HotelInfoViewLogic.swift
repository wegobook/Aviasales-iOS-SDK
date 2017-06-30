class HotelInfoViewLogic: NSObject {

    func shouldShowRatingView(_ hotel: HDKHotel) -> Bool {
        return hotel.rating > 0
    }

    func shouldHideStars(_ hotel: HDKHotel) -> Bool {
        let hotelType = HotelPropertyTypeUtils.hotelPropertyTypeEnum(hotel)

        return (hotel.isRentals || hotel.stars == 0) && hotelType != .unknown
    }

    func hotelTypeDescription(_ hotel: HDKHotel) -> String? {
         return HotelPropertyTypeUtils.localizedHotelPropertyType(hotel)
    }

}
