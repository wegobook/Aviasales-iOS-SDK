import HotellookSDK

@objc protocol PeekHotelVCDelegate: NSObjectProtocol {
    func showPeekDetails()
}

class PeekHotelVC: PeekTableVC {

    weak var delegate: PeekHotelVCDelegate?
    var shouldAddMapCell: Bool = true
    var hadTip: Bool = false

    override func createItems() -> [PeekItem] {
        var result: [PeekItem] = [RatingPeekItem(variant)]
        if shouldAddPriceCell() {
            result.append(PricePeekItem(variant))
        }
        if shouldAddMapCell {
            result.append(MapPeekItem(variant, filter: filter))
        } else {
            result.append(PhotoPeekItem(variant))
        }

        return result
    }

    private func shouldAddPriceCell() -> Bool {
        return variant.filteredRooms.count > 0
    }

    // MARK: - Preview actions

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        var actionsToReturn: [UIPreviewActionItem] = []

        actionsToReturn.append(createShowDetailsPreviewActionItem())

        if shouldAddPriceCell() {
            actionsToReturn.append(createBookPreviewActionItem())
        }

        return actionsToReturn
    }

    @available(iOS 9.0, *)
    fileprivate func createBookPreviewActionItem() -> UIPreviewActionItem {
        let bookStringWithPrice = NSMutableAttributedString(string: NSLS("HL_HOTEL_PEEK_BOOK_BUTTON_TITLE"))
        let appFont = UIFont.boldSystemFont(ofSize: 17.0)
        let minPrice = StringUtils.attributedPriceString(withPrice: self.variant.minPrice, currency: self.variant.searchInfo.currency, font: appFont)
        bookStringWithPrice.append(minPrice)

        let bookTitleWithPrice = bookStringWithPrice.string
        let bookTitleWithoutPrice = NSLS("HL_HOTEL_DETAIL_BOOK_BUTTON_TITLE")

        let bookTitle = bookTitleWithPrice.characters.count <= 35 ? bookTitleWithPrice : bookTitleWithoutPrice

        let bookAction = UIPreviewAction(title: bookTitle, style: .default) { [weak self]  (action, viewController) -> Void in
            guard let `self` = self else { return }

            let room = self.variant.sortedRooms[0]

            let browser = BookBrowserController(nibName: "BookBrowserController", bundle: nil)
            browser.room = room
            browser.providesPresentationContextTransitionStyle = true
            browser.definesPresentationContext = true
            self.viewControllerToShowBrowser?.present(browser, animated: true, completion: nil)
        }

        return bookAction
    }

    @available(iOS 9.0, *)
    fileprivate func createShowDetailsPreviewActionItem() -> UIPreviewActionItem {
        let showDetailsTitle = NSLS("HL_HOTEL_PEEK_SHOW_DETAILS_BUTTON_TITLE")

        let showDetailsAction = UIPreviewAction(title: showDetailsTitle, style: .default) { [weak self]  (action, viewController) -> Void in
            self?.delegate?.showPeekDetails()
        }

        return showDetailsAction
    }

}
