import Foundation
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

enum TripTypes: String {
    case unknown
    case solo
    case business
    case couple
    case family

    static let sortedValues = [solo, business, couple, family]
}

class HLHotelDetailsTripTypeCellFactory {

    static let kDefaultTripTypeIconName = "soloTripTypeIcon"

    fileprivate static let tripTypeNames = [
            TripTypes.solo: NSLS("HL_HOTEL_DETAIL_TRIPTYPE_SOLO"),
            TripTypes.business: NSLS("HL_HOTEL_DETAIL_TRIPTYPE_BUSINESS"),
            TripTypes.couple: NSLS("HL_HOTEL_DETAIL_TRIPTYPE_COUPLE"),
            TripTypes.family: NSLS("HL_HOTEL_DETAIL_TRIPTYPE_FAMILY")
    ]

    fileprivate static let tripTypeImageNames = [
            TripTypes.solo: "soloTripTypeIcon",
            TripTypes.business: "businessTripTypeIcon",
            TripTypes.couple: "coupleTripTypeIcon",
            TripTypes.family: "familyTripTypeIcon"
    ]

    class func createTripTypeItems(_ trustyou: HDKTrustyou, filter: Filter?, tableView: UITableView) -> [TableItem] {

        var flattenTripTypes: [TripTypeItem] = []

        let tripTypeCandidates = self.parseTripTypes(trustyou)
        if tripTypeCandidates.hdk_atLeastOneConfirms({$0.percentage > 0}) && tripTypeCandidates.hdk_allObjectsConfirm({$0.percentage < 100}) {
            let sortedTripTypeCandidates = self.sortTripTypeItems(tripTypeCandidates)
            flattenTripTypes.append(contentsOf: sortedTripTypeCandidates)
        }

        if let langTripTypeItem = self.parseLangTripType(trustyou) {
            let shouldShowLangTripTypeItem = (langTripTypeItem.percentage > 0 && langTripTypeItem.percentage < 100)
            if shouldShowLangTripTypeItem {
                flattenTripTypes.append(langTripTypeItem)
            }
        }

        return HLTwoColumnCellsDataSource(flattenedItems: flattenTripTypes, cellWidth: tableView.bounds.width, canFillHalfScreen: HLHotelDetailsFeaturesCell.canFillHalfScreen).splitItemsLongAtBottom()
    }

    fileprivate class func sortTripTypeItems(_ tripTypeItems: [TripTypeItem]) -> [TripTypeItem] {

        let sortedTripTypes = TripTypes.sortedValues
        return tripTypeItems.sorted(by: { (firstItem: TripTypeItem, secondItem: TripTypeItem) -> Bool in
            if firstItem.percentage != secondItem.percentage {
                return firstItem.percentage > secondItem.percentage
            }

            return sortedTripTypes.index(of: firstItem.tripType) < sortedTripTypes.index(of: secondItem.tripType)
        })
    }

    fileprivate class func parseTripTypes(_ trustyou: HDKTrustyou) -> [TripTypeItem] {

        guard trustyou.tripTypeDistribution.count > 0 else { return [] }

        let tripTypesMap: [TripTypes: HDKTripTypeDistribution] = trustyou.tripTypeDistribution.hdk_toDictionary {
            guard let key = TripTypes(rawValue: $0.type) else { return nil }
            return (key, $0)
        }

        var result: [TripTypeItem] = []
        let allowedTripTypes = self.tripTypeNames.keys
        for tripType in allowedTripTypes {
            let percentage = tripTypesMap[tripType]?.percentage ?? 0

            let name = tripTypeNameWithKey(tripType, percentage: percentage)
            let image = tripTypeIconWithKey(tripType)
            let item = TripTypeItem(name: name, image: image, percentage: percentage, tripType: tripType)
            result.append(item)
        }

        return result
    }

    fileprivate class func parseLangTripType(_ trustyou: HDKTrustyou) -> TripTypeItem? {
        let userReviewLangName = HLLocaleInspector.userReviewLangName()

        for langDistribution in trustyou.languageDistribution {

            let langName = langDistribution.lang
            guard langName == userReviewLangName else { continue }

            let percentage = langDistribution.percentage
            guard percentage >= 0 else { continue }

            let name = self.langNameWithKey(langName, percentage: percentage)
            let image = UIImage(named: "guestsLanguageSplitIcon")!
            let item = TripTypeItem(name: name, image: image, percentage: percentage, tripType: TripTypes.unknown)
            return item
        }
        return nil
    }

    class func langNameWithKey(_ key: String, percentage: Int) -> String {
        let name = "name" //HLLocaleInspector.localizedUserReviewLangName(forLang: key)
        return "\(percentage)% — \(name)"
    }

    class func tripTypeNameWithKey(_ key: TripTypes, percentage: Int) -> String {
        let name = tripTypeNames[key] ?? key.rawValue
        return "\(percentage)% — \(name)"
    }

    class func tripTypeIconWithKey(_ key: TripTypes) -> UIImage {
        let image: UIImage

        if let imageName = tripTypeImageNames[key] {
            image = UIImage(named: imageName)!
        } else {
            image = UIImage(named: kDefaultTripTypeIconName)!
        }

        return image
    }
}
