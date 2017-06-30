class HotelDetailsTargetConfiguration: NSObject {

    func shouldShowRatingView(_ variant: HLResultVariant) -> Bool {
        return variant.hotel.rating > 0
    }

}
