import UIKit

class StringFilterItem {
    var filterString: String?
    var text: String?

    init(filterString: String, text: String) {
        self.filterString = filterString
        self.text = text
    }

    func isSelected(for filter: Filter) -> Bool {
        return false
    }

    func changeValue(for filter: Filter) {
        // Override in subclass
    }
}

class DummyFilterItem: StringFilterItem {
    override func changeValue(for filter: Filter) {
    }
}

class GateFilterItem: StringFilterItem {

    override func isSelected(for filter: Filter) -> Bool {
        if let filterString = filterString {
            return filter.gatesToFilter.contains(filterString)
        }

        return super.isSelected(for: filter)
    }

    override func changeValue(for filter: Filter) {
        if let filterString = filterString {
            if filter.gatesToFilter.contains(filterString) {
                filter.gatesToFilter.removeObject(filterString)
            } else {
                filter.gatesToFilter.append(filterString)
            }
        }
    }
}

class DistrictFilterItem: StringFilterItem {
    override func isSelected(for filter: Filter) -> Bool {
        if let filterString = filterString {
            return filter.districtsToFilter.contains(filterString)
        }

        return super.isSelected(for: filter)
    }

    override func changeValue(for filter: Filter) {
        if let filterString = filterString {
            if filter.districtsToFilter.contains(filterString) {
                filter.districtsToFilter.removeObject(filterString)
            } else {
                filter.districtsToFilter.append(filterString)
            }
        }
    }
}

class PropertyTypeFilterItem: StringFilterItem {
    var availableTypes: Set<HLHotelPropertyType>

    init(availableTypes: Set<HLHotelPropertyType>, text: String) {
        self.availableTypes = availableTypes
        super.init(filterString: "", text: text)
    }

    override func changeValue(for filter: Filter) {
        if filter.availablePropertyTypes.isSuperset(of: availableTypes) {
            filter.availablePropertyTypes.subtract(availableTypes)
        } else {
            filter.availablePropertyTypes = filter.availablePropertyTypes.union(availableTypes)
        }
    }

    override func isSelected(for filter: Filter) -> Bool {
        return filter.availablePropertyTypes.isSuperset(of: availableTypes)
    }
}

class SharedBathroomFilterItem: StringFilterItem {
    override func isSelected(for filter: Filter) -> Bool {
        return filter.hideSharedBathroom
    }

    override func changeValue(for filter: Filter) {
        filter.hideSharedBathroom = !filter.hideSharedBathroom
    }
}

class RoomAmenityFilterItem: StringFilterItem {

    override func isSelected(for filter: Filter) -> Bool {
        if let filterString = filterString {
            return filter.options.contains(filterString)
        }

        return super.isSelected(for: filter)
    }

    override func changeValue(for filter: Filter) {
        if let filterString = filterString {
            if filter.options.contains(filterString) {
                filter.options.removeObject(filterString)
            } else {
                filter.options.append(filterString)
            }
        }
    }
}

class HotelAmenityFilterItem: StringFilterItem {

    override func isSelected(for filter: Filter) -> Bool {
        if let filterString = filterString {
            return filter.amenities.contains(filterString)
        }

        return super.isSelected(for: filter)
    }

    override func changeValue(for filter: Filter) {
        if let filterString = filterString {
            if filter.amenities.contains(filterString) {
                filter.amenities.removeObject(filterString)
            } else {
                filter.amenities.append(filterString)
            }
        }
    }
}
