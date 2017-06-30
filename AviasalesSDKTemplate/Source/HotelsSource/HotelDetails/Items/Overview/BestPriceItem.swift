class BestPriceItem: TableItem {

    private let kLoadingPriceCellHeight: CGFloat = 50.0

    var variant: HLResultVariant
    var priceInfoState: HotelDetailsTabState
    var bookHandler: (() -> Void)?
    var photoHandler: (() -> Void)?
    var allPricesHandler: (() -> Void)?
    var changeParamsHandler: (() -> Void)?
    var shouldShowPhotoButton = true

    init(variant: HLResultVariant, priceInfoState: HotelDetailsTabState) {
        self.variant = variant
        self.priceInfoState = priceInfoState
    }

    override func cell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch priceInfoState {
        case .completed:
            let ctaCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsPriceCTACell.hl_reuseIdentifier(), for: indexPath) as! HLHotelDetailsPriceCTACell
            if shouldShowPhotoButton {
                ctaCell.showPhotosButton()
            } else {
                ctaCell.hidePhotosButton()
            }
            let room = variant.roomWithMinPrice!
            let currency = variant.searchInfo.currency
            let duration = variant.duration
            ctaCell.canHighlightPrivatePrice = true
            ctaCell.configure(for: room, currency: currency, duration: duration)
            ctaCell.bookHandler = bookHandler
            ctaCell.photoHandler = photoHandler
            return ctaCell

        case .loading:
            let activityCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsActivityIndicatorTableCell.hl_reuseIdentifier()) as! HLHotelDetailsActivityIndicatorTableCell
            activityCell.startAnimating()
            activityCell.indicatorVerticalConstraint.constant = 5
            activityCell.backgroundColor = UIColor.white
            activityCell.last = true
            return activityCell

        case .searchInfoSelectionNeeded, .noPrices, .failed:
            let noPricesCell = tableView.dequeueReusableCell(withIdentifier: HLHotelDetailsNoPriceCell.hl_reuseIdentifier()) as! HLHotelDetailsNoPriceCell
            noPricesCell.noPriceReasonText = noPriceReasonTextByState(priceInfoState)
            noPricesCell.changeHandler = changeParamsHandler
            noPricesCell.changeButton.isHidden = false
            noPricesCell.changeButton.setTitle(noPriceChangeButtonTextByState(priceInfoState), for: .normal)

            noPricesCell.last = true
            return noPricesCell

        case .none:
            assertionFailure()
            return HLTableViewCell()
        }
    }

    override func cellHeight(tableWidth: CGFloat) -> CGFloat {
        switch priceInfoState {
        case .completed:
            guard let room = variant.roomWithMinPrice else { return 0.0 }

            let currency = variant.searchInfo.currency
            let duration = variant.duration
            return HLHotelDetailsPriceCTACell.calculateCellHeight(tableWidth, room: room, currency: currency, duration: duration)
        case .loading:
            return kLoadingPriceCellHeight
        case .searchInfoSelectionNeeded, .noPrices, .failed:
            let text = noPriceReasonTextByState(priceInfoState)
            return HLHotelDetailsNoPriceCell.estimatedHeight(text, width: tableWidth, canChangeSearchInfo: true)
        default:
            return 0.0
        }
    }

    private func noPriceReasonTextByState(_ priceState: HotelDetailsTabState) -> String {
        switch priceState {
        case .searchInfoSelectionNeeded:
            return NSLS("HL_HOTEL_DETAIL_NO_DATES_SELECTED_TITLE")
        case .noPrices, .failed:
            return NSLS("HL_HOTEL_DETAIL_NO_ROOMS_ERROR_TITLE")
        default:
            return ""
        }
    }

    private func noPriceChangeButtonTextByState(_ priceState: HotelDetailsTabState) -> String {
        switch priceState {
        case .noPrices, .failed, .searchInfoSelectionNeeded:
            return NSLS("HL_HOTEL_DETAIL_CHANGE_SEARCHINFO_BUTTON_TITLE")
        default:
            return NSLS("HL_HOTEL_DETAIL_RESTART_OUTDATED_SEARCH_TITLE")
        }
    }

    private func searchInfoForVariant(_ variant: HLResultVariant?) -> HLSearchInfo? {
        guard let variant = variant else { return nil }

        let newSearchInfo = variant.searchInfo.copy() as? HLSearchInfo
        if variant.searchInfo.searchInfoType != .hotel {
            newSearchInfo?.city = variant.hotel.city
            newSearchInfo?.hotel = nil
            newSearchInfo?.locationPoint = nil
        }
        newSearchInfo?.updateExpiredDates()

        return newSearchInfo
    }

}
