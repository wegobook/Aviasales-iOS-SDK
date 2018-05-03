func == (left: HLVariantItem, right: HLVariantItem) -> Bool {
    return left.variant == right.variant
}

func == (left: HLCollectionItem, right: HLCollectionItem) -> Bool {
    return left === right
}

@objcMembers
class HLCollectionItem: NSObject {

    var progress: Float = 0.0

    var needShowProgress: Bool {
        return false
    }
}

@objcMembers
class HLCityItem: HLCollectionItem {

    var city: HDKCity!

    override var needShowProgress: Bool {
        return true
    }

    class func createItems(_ cities: [HDKCity]) -> [HLCityItem] {
        var items: [HLCityItem] = []
        for city in cities {
            let item = HLCityItem(city: city)
            items.append(item)
        }

        return items
    }

    init(city: HDKCity) {
        self.city = city
    }

}

@objcMembers
class HLVariantItem: HLCollectionItem {

    var photoIndex: Int = 0
    var variant: HLResultVariant

    class func find(variant: HLResultVariant, inItems items: [HLVariantItem]) -> HLVariantItem? {
        for item in items {
            if item.variant.isEqual(variant) {
                return item
            }
        }

        return nil
    }

    class func find(hotel: HDKHotel, inItems items: [HLVariantItem]) -> HLVariantItem? {
        for item in items {
            if item.variant.hotel.isEqual(hotel) {
                return item
            }
        }

        return nil
    }

    class func createItems(_ variants: [HLResultVariant]) -> [HLVariantItem] {
        var items: [HLVariantItem] = []
        for variant in variants {
            let item = HLVariantItem(variant: variant)
            items.append(item)
        }

        return items
    }

    init(variant: HLResultVariant) {
        self.variant = variant
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let item = object as? HLVariantItem {
            return self.variant.isEqual(item.variant)
        }

        return false
    }

    override var hash: Int {
        return self.variant.hash
    }

}
