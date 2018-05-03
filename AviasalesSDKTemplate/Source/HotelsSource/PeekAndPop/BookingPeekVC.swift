class BookingPeekVC: PeekTableVC {

    var room: HDKRoom?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.register(AccommodationCell.self, forCellReuseIdentifier: AccommodationCell.hl_reuseIdentifier())
        tableView?.hl_registerNib(withName: PeekFullInfoCell.hl_reuseIdentifier())
    }

    override func createItems() -> [PeekItem] {
        var result = [FullInfoItem(variant), PricePeekItem(variant, room: room)]
        result.append(contentsOf: accomodationItems())

        return result
    }

    func accomodationItems() -> [PeekItem] {
        view.layoutIfNeeded()
        guard let width = tableView?.bounds.width else { return [] }
        let accItems = HLHotelDetailsCommonCellFactory.accommodationItems(variant, startDate: variant.searchInfo.checkInDate, endDate: variant.searchInfo.checkOutDate, containerWidth: width)
        var result: [AccomodationPeekItem] = []
        for i in 0..<accItems.count {
            let infoItem = accItems[i]
            let accItem = AccomodationPeekItem(variant)
            accItem.infoItem = infoItem
            result.append(accItem)
        }

        return result
    }

    // MARK: - Preview actions

    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        if let room = room {
            return [createBookPreviewActionItem(room)]
        }
        return []
    }

    @available(iOS 9.0, *)
    fileprivate func createBookPreviewActionItem(_ room: HDKRoom) -> UIPreviewActionItem {
        let bookStringWithPrice = NSMutableAttributedString(string: NSLS("HL_HOTEL_PEEK_BOOK_BUTTON_TITLE"))
        let appFont = UIFont.boldSystemFont(ofSize: 17.0)
        let price = StringUtils.attributedPriceString(withPrice: room.price, currency: self.variant.searchInfo.currency, font: appFont)
        bookStringWithPrice.append(price)

        let bookTitleWithPrice = bookStringWithPrice.string
        let bookTitleWithoutPrice = NSLS("HL_HOTEL_DETAIL_BOOK_BUTTON_TITLE")

        let bookTitle = bookTitleWithPrice.count <= 35 ? bookTitleWithPrice : bookTitleWithoutPrice

        let bookAction = UIPreviewAction(title: bookTitle, style: .default) { [weak self]  (action, viewController) -> Void in
            guard let `self` = self else { return }

            let bookBrowserPresenter = BookBrowserViewPresenter(room: room)
            let browserViewController = BrowserViewController(presenter: bookBrowserPresenter)
            let navigationController = JRNavigationController(rootViewController: browserViewController)

            self.viewControllerToShowBrowser?.present(navigationController, animated: true, completion: nil)
        }

        return bookAction
    }
}
