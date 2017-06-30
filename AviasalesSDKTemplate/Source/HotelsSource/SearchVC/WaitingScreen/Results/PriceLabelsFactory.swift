class RootOptionItem {
    let text: String
    let icon: UIImage
    let textColor: UIColor

    init(text: String, icon: UIImage, textColor: UIColor) {
        self.text = text
        self.icon = icon
        self.textColor = textColor
    }
}

class DefaultOptionItem: RootOptionItem {
    init(text: String) {
        super.init(text: text, icon: UIImage.peekCheckImage, textColor: JRColorScheme.darkTextColor())
    }
}

class MissOptionItem: RootOptionItem {
    init(text: String) {
        super.init(text: text, icon: UIImage.peekCheckMissImage, textColor: JRColorScheme.darkTextColor())
    }
}

class WarningOptionItem: RootOptionItem {
    init(text: String) {
        super.init(text: text, icon: UIImage.peekCheckWarningImage, textColor: JRColorScheme.darkTextColor())
    }
}

class PriceLabelsFactory {
    static let current: PriceLabelsFactory = PriceLabelsFactory()

    func optionItems(from room: HDKRoom) -> [RootOptionItem] {

        var optionsItems: [RootOptionItem] = []

        addBathroom(to: &optionsItems, room: room)
        addBreakfast(to: &optionsItems, room: room)
        addAllInclusive(to: &optionsItems, room: room)
        addViewSentence(to: &optionsItems, room: room)
        addFreeWifi(to: &optionsItems, room: room)
        addSmoking(to: &optionsItems, room: room)
        addHotelWebsite(to: &optionsItems, room: room)
        addPayNow(to: &optionsItems, room: room)
        addRefundable(to: &optionsItems, room: room)
        addCardNotRequired(to: &optionsItems, room: room)
        addPrivatePrice(to: &optionsItems, room: room)
        addRoomsAvailable(to: &optionsItems, room: room)

        return optionsItems
    }

    private func addBathroom(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if let bathroom = room.options.privateBathroom {
            if !bathroom {
                optionsItems.append(MissOptionItem(text: NSLS("HL_HOTEL_DETAIL_SHARED_BATHROOM_OPTION")))
            }
        }
    }

    private func addBreakfast(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if !room.allInclusive {
            if room.hasBreakfast {
                optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_BREAKFAST_OPTION_TITLE")))
            } else {
                optionsItems.append(MissOptionItem(text: NSLS("HL_HOTEL_DETAIL_NO_BREAKFAST_OPTION_TITLE")))
            }
        }
    }

    private func addAllInclusive(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.allInclusive {
            optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_ALL_INCLUSIVE_OPTION_TITLE")))
        }
    }

    private func addViewSentence(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if let viewSentence = room.options.viewSentence, !viewSentence.isEmpty {
            optionsItems.append(DefaultOptionItem(text: viewSentence))
        }
    }

    private func addFreeWifi(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.hasWifi {
            optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_FREEWIFI_OPTION_TITLE")))
        }
    }

    private func addSmoking(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.smokingAllowed {
            optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_SMOKING_OPTION_TITLE")))
        }
    }

    private func addHotelWebsite(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.hasHotelWebsiteOption {
            optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_HOTEL_SITE_OPTION_TITLE")))
        }
    }

    private func addPayNow(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if let payNow = room.options.deposit {
            if payNow {
                optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_DEPOSIT_TRUE_OPTION_TITLE")))
            } else {
                optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_DEPOSIT_FALSE_OPTION_TITLE")))
            }
        }
    }

    private func addRefundable(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.refundable {
            optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_REFUNDABLE_OPTION_TITLE")))
        }
    }

    private func addCardNotRequired(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if let cardRequired = room.options.cardRequired {
            if !cardRequired {
                optionsItems.append(DefaultOptionItem(text: NSLS("HL_HOTEL_DETAIL_CARD_REQUIRED_FALSE_OPTION_TITLE")))
            }
        }
    }

    private func addPrivatePrice(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if room.hasMobileOrPrivatePriceOption {
            optionsItems.append(WarningOptionItem(text: NSLS("HL_HOTEL_DETAIL_PRIVATE_PRICE_OPTION_TITLE")))
        }
    }

    private func addRoomsAvailable(to optionsItems: inout [RootOptionItem], room: HDKRoom) {
        if let roomsAvailable = room.options.available, roomsAvailable > 0 {
            optionsItems.append(WarningOptionItem(text: StringUtils.roomsAvailableString(withCount: roomsAvailable)))
        }
    }
}
