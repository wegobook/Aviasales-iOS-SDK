import UIKit

class HotelRatingVC: HotelDetailsMoreTableVC, PeekVCProtocol {
    private let filter: Filter?
    var commitBlock: (() -> Void)?

    init(variant: HLResultVariant, filter: Filter?) {
        self.filter = filter
        super.init(variant: variant)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTable.backgroundColor = .white
        contentTable?.estimatedRowHeight = 200
        title = NSLS("HL_HOTEL_DETAIL_SEGMENTED_RATING_SECTION")
        registerCells()
        sections = createSections()
    }

    private func registerCells() {
        contentTable.hl_registerNib(withName: HLHotelDetailsUsefullInfoCell.hl_reuseIdentifier())
        contentTable.hl_registerNib(withName: HLHotelDetailsRatingSummaryCell.hl_reuseIdentifier())
        contentTable.hl_registerNib(withName: HLHotelDetailsFeaturesCell.hl_reuseIdentifier())
        contentTable.hl_registerNib(withName: HLHotelDetailsRatingDetailsCell.hl_reuseIdentifier())
        contentTable.hl_registerNib(withName: HLHotelDetailsTableRatingCell.hl_reuseIdentifier())
        contentTable.register(HotelDetailsReviewHighlightCell.self, forCellReuseIdentifier: HotelDetailsReviewHighlightCell.hl_reuseIdentifier())
    }

    func createSections() -> [TableSection] {
        var result: [TableSection] = []

        result = addSummaryDescriptionSection(sections: result, trustyou: variant.hotel.trustyou)
        result = addTripTypesSection(sections: result, trustyou: variant.hotel.trustyou)
        result = addGoodToKnowSection(sections: result, trustyou: variant.hotel.trustyou)
        result = addReviewHighlightsSection(sections: result, trustyou: variant.hotel.trustyou)

        return result
    }

    private func addTripTypesSection(sections: [TableSection], trustyou: HDKTrustyou?) -> [TableSection] {
        guard let trustyou = trustyou else { return sections }

        var result = sections

        let tripTypeItems = HLHotelDetailsTripTypeCellFactory.createTripTypeItems(trustyou, filter: filter, tableView: contentTable)
        if tripTypeItems.count > 0 {
            TableItem.setFirstAndLast(items: tripTypeItems)
            let section = TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_TRIPTYPES"), items: tripTypeItems)
            result.append(section)
        }
        return result
    }

    private func addSummaryDescriptionSection(sections: [TableSection], trustyou: HDKTrustyou?) -> [TableSection] {
        guard let trustyou = trustyou else { return sections }
        var result = sections
        let items = [TableRatingItem(trustYou: trustyou, shortItems: false, moreHandler: nil, shouldShowSeparator: true)]
        let section = RatingSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_RATING_RATING_SUMMARY"), items: items)
        result.append(section)

        return result
    }

    private func addGoodToKnowSection(sections: [TableSection], trustyou: HDKTrustyou?) -> [TableSection] {
        guard let trustyou = trustyou else { return sections }

        var result = sections
        if trustyou.goodToKnow.count > 0 {
            var items: [GoodToKnowItem] = []
            for elem in trustyou.goodToKnow {
                items.append(GoodToKnowItem(name: elem.text, score: elem.score))
            }
            TableItem.setFirstAndLast(items: items)
            result.append(TableSection(name: NSLS("HL_HOTEL_DETAIL_INFORMATION_GOODTOKNOW_SECTION"), items: items))
        }

        return result
    }

    private func addReviewHighlightsSection(sections: [TableSection], trustyou: HDKTrustyou?) -> [TableSection] {
        guard let trustyou = trustyou else { return sections }

        var result = sections
        if trustyou.reviewHighlights.count > 0 {
            var items: [ReviewHighlightsItem] = []
            for review in trustyou.reviewHighlights {
                let item = ReviewHighlightsItem(name: "", reviewHighlight: review)
                items.append(item)
            }

            TableItem.setFirstAndLast(items: items)
            result.append(TableSection(name: NSLS("HL_HOTEL_DETAIL_HEADER_TITLE_REVIEW_HIGHLIGHTS"), items: items))
        }

        return result
    }
}
