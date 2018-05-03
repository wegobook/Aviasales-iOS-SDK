struct FilterCellIdentifiers {
    static let property = "propertyFilterCell"
    static let foodPayment = "foodPaymentFilterCell"
    static let roomAmenities = "roomAmenitiesFilterCell"
    static let hotelAmenities = "hotelAmenitiesFilterCell"
}

class FilterCellFactory: NSObject {

    weak var controlDelegate: FilterControlDelegate?
    weak var pointSelectionDelegate: PointSelectionDelegate?
    weak var chooseSelectionDelegate: ChooseSelectionDelegate?
    weak var cancelableFilterViewDelegate: CancelableFilterViewDelegate?

    var filter: Filter
    var searchInfo: HLSearchInfo

    init(filter: Filter, searchInfo: HLSearchInfo) {
        self.filter = filter
        self.searchInfo = searchInfo
    }

    func createSections() -> [FilterSection] {
        var sections = [slidersSection(), propertyTypeSection(), roomAmenitiesSection(), hotelAmenitiesSection(), nameSection()]

        if let districtsSection = districtsSection() {
            sections.append(districtsSection)
        }

        if let gatesSection = gatesSection() {
            sections.append(gatesSection)
        }

        let foodPaymentIndex = min(1, sections.count)
        sections.insert(foodPaymentSection(), at: foodPaymentIndex)

        let index = min(3, sections.count)
        sections.insert(createStarSection(), at: index)

        return sections
    }

    func slidersSection() -> FilterSection {
        return FilterSection(name: nil, items: createSliderItems())
    }

    func createStarSection() -> FilterSection {
        return FilterSection(name: NSLS("HL_LOC_FILTER_STARS_SECTION"), items: [FilterStarItem(filter: filter)])
    }

    func propertyTypeSection() -> FilterSection {
        let elements = createPropertyElements()
        let items = [FilterMultiAmenitiesItem(filter: filter, elements: elements, cellIdentifier: FilterCellIdentifiers.property)] + unwantedVariantsItems()

        return FilterSection(name: NSLS("HL_LOC_FILTER_PROPERTY_TYPE_SECTION"), items: items)
    }

    func hideUnwantedVariantsSection() -> FilterSection {
        return FilterSection(name: NSLS("HL_LOC_FILTER_UNWANTED_VARIANTS_SECTION"), items: unwantedVariantsItems())
    }

    func foodPaymentSection() -> FilterSection {
        var elements = [RoomAmenityFilterItem(filterString: RoomOptionConsts.kBreakfastOptionKey, text: NSLS("HL_LOC_FILTER_BREAKFAST_CRITERIA")),
                        RoomAmenityFilterItem(filterString: RoomOptionConsts.kRefundableOptionKey, text: NSLS("HL_LOC_FILTER_REFUNDABLE_CRITERIA")),
                        RoomAmenityFilterItem(filterString: RoomOptionConsts.kPayNowOptionKey, text: NSLS("HL_LOC_FILTER_PAY_NOW_CRITERIA")),
                        RoomAmenityFilterItem(filterString: RoomOptionConsts.kPayLaterOptionKey, text: NSLS("HL_LOC_FILTER_PAY_LATER_CRITERIA"))]

        let allInclusiveCount = Int(truncating: filter.searchResult.counters.hotelsCountAccordingToOptions[RoomOptionConsts.kAllInclusiveOptionKey] ?? 0)
        if allInclusiveCount > 3 {
            let text = NSLS("HL_LOC_FILTER_ALL_INCLUSIVE_CRITERIA") + " (" + String(allInclusiveCount) + " " + NSLSP("HL_LOC_SEARCH_FORM_HOTEL", Float(allInclusiveCount)) + ")"
            let item = RoomAmenityFilterItem(filterString: RoomOptionConsts.kAllInclusiveOptionKey, text: text)
            elements = addItem(item, items: elements, desiredIndex: 1)
        }

        return FilterSection(name: NSLS("HL_LOC_FILTER_FOOD_PAYMENT_SECTION"), items: [FilterMultiAmenitiesItem(filter: filter, elements: elements, cellIdentifier: FilterCellIdentifiers.foodPayment)])
    }

    func roomAmenitiesSection() -> FilterSection {
        let elements = [
            SharedBathroomFilterItem(filterString: "", text: NSLS("HL_LOC_FILTERS_HIDE_SHARED_BATHROOM")),
            RoomAmenityFilterItem(filterString: RoomOptionConsts.kRoomWifiOptionKey, text: NSLS("HL_HOTEL_DETAIL_AMENITY_ROOMS_WIFI")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.airConditioning, text: NSLS("HL_LOC_FILTER_AMENITY_AIR_CONDITIONING")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.hairDryer, text: NSLS("HL_LOC_FILTER_AMENITY_HAIRDRYER")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.tv, text: NSLS("HL_LOC_FILTER_AMENITY_TV")),
            RoomAmenityFilterItem(filterString: RoomOptionConsts.kNiceViewOptionKey, text: NSLS("HL_LOC_FILTER_SIGHT_CRITERIA")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.safeBox, text: NSLS("HL_HOTEL_DETAIL_AMENITY_SAFE_BOX")),
            RoomAmenityFilterItem(filterString: RoomOptionConsts.kSmokingOptionKey, text: NSLS("HL_LOC_FILTER_AMENITY_SMOKING"))
        ]
        let items = [FilterMultiAmenitiesItem(filter: filter, elements: elements, cellIdentifier: FilterCellIdentifiers.roomAmenities)]

        return FilterSection(name: NSLS("HL_LOC_FILTER_ROOM_AMENITIES_SECTION"), items: items)
    }

    func hotelAmenitiesSection() -> FilterSection {
        let elements = [
            HotelAmenityFilterItem(filterString: AmenityShortConst.parking, text: NSLS("HL_LOC_FILTER_AMENITY_PARKING")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.restaurant, text: NSLS("HL_LOC_FILTER_AMENITY_RESTAURANT")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.pool, text: NSLS("HL_LOC_FILTER_AMENITY_POOL")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.fitness, text: NSLS("HL_LOC_FILTER_AMENITY_FITNESS")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.pets, text: NSLS("HL_LOC_FILTER_AMENITY_PETS")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.laundry, text: NSLS("HL_LOC_FILTER_AMENITY_LAUNDRY")),
            HotelAmenityFilterItem(filterString: AmenityShortConst.childrenActivities, text: NSLS("HL_LOC_FILTER_AMENITY_CHILDREN_CARE"))
        ]
        let items = [FilterMultiAmenitiesItem(filter: filter, elements: elements, cellIdentifier: FilterCellIdentifiers.hotelAmenities)]

        return FilterSection(name: NSLS("HL_LOC_FILTER_HOTEL_AMENITIES_SECTION"), items: items)
    }

    func districtsSection() -> FilterSection? {
        let item = districtItem()
        if shouldAdd(item) {
            return FilterSection(name: NSLS("HL_LOC_FILTER_DISTRICTS_SECTION"), items: [item])
        } else {
            return nil
        }
    }

    func gatesSection() -> FilterSection? {
        let item = gateItem()
        if shouldAdd(item) {
            return FilterSection(name: NSLS("HL_LOC_FILTER_GATES_SECTION"), items: [item])
        } else {
            return nil
        }
    }

    func nameSection() -> FilterSection {
        let item = FilterNameItem(filter)
        item.selectionBlock = { [weak self] in
            self?.controlDelegate?.openNameFilterScreen?()
        }

        return FilterSection(name: NSLS("HL_LOC_FILTER_HOTEL_NAME_SECTION"), items: [item])
    }

    // MARK: - Items creation

    func createSliderItems() -> [FilterSliderItem] {
        var result: [FilterSliderItem] = []
        if !filter.allVariantsHaveSamePrice() {
            result.append(FilterPriceItem(filter: filter, controlDelegate: controlDelegate, currency: searchInfo.currency))
        }
        let distanceItem = FilterDistanceItem(filter: filter, controlDelegate: controlDelegate)
        distanceItem.pointSelectionDelegate = pointSelectionDelegate
        result.append(distanceItem)

        let item = FilterRatingItem(filter: filter, controlDelegate: controlDelegate)
        result = addItem(item, items: result, desiredIndex: 1)

        return result
    }

    func createPropertyElements() -> [StringFilterItem] {
        let hotelsElement = PropertyTypeFilterItem(availableTypes: HLHotelPropertyType.hotelValues, text: NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_HOTEL_FILTER"))
        let apartsElement = PropertyTypeFilterItem(availableTypes: HLHotelPropertyType.apartmentValues, text: NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_APARTMENT_FILTER"))
        let hostelsElement = PropertyTypeFilterItem(availableTypes: HLHotelPropertyType.hostelValues, text: NSLS("HOTEL_DETAILS_HOTEL_PROPERTY_TYPE_HOSTEL_FILTER"))

        return [hotelsElement, apartsElement, hostelsElement]
    }

    func unwantedVariantsItems() -> [TableItem] {
        return [sharedRoomsItem(), noRoomsItem()]
    }

    private func selectOption(_ option: String) {
        guard var options = filter.options else { return }
        if options.contains(option) {
//            options.removeObject(option)
        } else {
            options.append(option)
        }
        filter.options = options
        filter.filter()
    }

    private func isOptionSelected(_ option: String) -> Bool {
        return filter.options.contains(option)
    }

    func sharedRoomsItem() -> FilterSelectionItem {
        let item = FilterSelectionItem(title: NSLS("HL_LOC_FILTERS_HIDE_DORMITORY"))
        item.selectionBlock = { [weak self] in
            guard let `self` = self else { return }
            if let cell = item.cell {
                cell.active = !cell.active
            }
            self.filter.hideDormitory = !self.filter.hideDormitory
            self.filter.filter()
        }
        item.active = filter.hideDormitory

        return item
    }

    func noRoomsItem() -> FilterSelectionItem {
        let item = FilterSelectionItem(title: NSLS("HL_LOC_FILTERS_HIDE_NO_ROOMS"))
        item.selectionBlock = { [weak self] in
            guard let `self` = self else { return }
            if let cell = item.cell {
                cell.active = !cell.active
            }
            self.filter.hideHotelsWithNoRooms = !self.filter.hideHotelsWithNoRooms
            self.filter.filter()
        }
        item.active = filter.hideHotelsWithNoRooms

        return item
    }

    func districtItem() -> FilterDistrictsItem {
        let item = FilterDistrictsItem(filter: filter)
        setDelegates(for: item)

        return item
    }

    func gateItem() -> FilterGatesItem {
        let item = FilterGatesItem(filter: filter)
        setDelegates(for: item)

        return item
    }

    func setDelegates(for item: CancelableFilterItem) {
        item.delegate = chooseSelectionDelegate
//        item.cancelableDelegate = cancelableFilterViewDelegate
    }

    func shouldAdd(_ item: CancelableFilterItem) -> Bool {
        return item.allItems(for: filter).compactMap({$0}).count > 0
    }

    // MARK: - Utils

    func addItem<T>(_ item: T, items: [T], desiredIndex: Int) -> [T] {
        var result = items
        var index = max(0, desiredIndex)
        index = min(result.count, index)
        result.insert(item, at: index)

        return result
    }
}
