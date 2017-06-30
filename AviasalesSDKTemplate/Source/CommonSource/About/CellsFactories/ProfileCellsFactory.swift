@objc protocol ProfileCellFactoryProtocol: NSObjectProtocol {
    func createSections(_ delegate: ProfileTableItemDelegate) -> ProfileSections
}

@objc protocol ProfileTableItemDelegate: NSObjectProtocol {
    func canSendEmail() -> Bool
    func sendEmail()
    func rateApp()
    func canRateApp() -> Bool
    func showDevSettings()
    func openCurrencySelector()
}

@objc class ProfileCellsFactory: NSObject, ProfileCellFactoryProtocol {

    // MARK: - ProfileCellFactoryProtocol

    func createSections(_ delegate: ProfileTableItemDelegate) -> ProfileSections {
        let result = ProfileSections()

        result.sections.append(createCurrencySection(delegate))

        result.mainSectionIndex = result.sections.count
        result.sections.append(createMainSection(delegate))

        return result
    }

    func createCurrencySection(_ delegate: ProfileTableItemDelegate) -> AboutTableSection {
        let currencyItem = HLProfileCurrencyItem(title: NSLS("HL_LOC_ABOUT_CURRENCY"),
                                         action: { [weak delegate] in  delegate?.openCurrencySelector() }, active: false)
        currencyItem.currency = InteractionManager.shared.currency
        currencyItem.accessibilityIdentifier = "HL_LOC_ABOUT_CURRENCY"

        return AboutTableSection(items: [currencyItem])
    }

    func createMainSection(_ delegate: ProfileTableItemDelegate) -> AboutTableSection {
        var items: [HLProfileTableItem] = []

        if delegate.canSendEmail() {
            let mailItem = disclosureItem(NSLS("HL_LOC_ABOUT_EMAIL_TITLE"), action: { [weak delegate] in delegate?.sendEmail() })
            items.append(mailItem)
        }

        if delegate.canRateApp() {
            let rateItem = disclosureItem(NSLS("LOC_RATE_APP_TITLE"), action: { [weak delegate] in delegate?.rateApp() })
            items.append(rateItem)
        }

        if !AppStore() {
            items.append(disclosureItem("Developer settings", action: { [weak delegate] in delegate?.showDevSettings() }))
        }

        return AboutTableSection(items: items)
    }

    // MARK: - Items creation

    func disclosureItem(_ title: String, action: @escaping (ProfileItemAction), accessibilityIdentifier: String? = nil) -> HLProfileTableItem {
        let item = HLProfileTableItem(title: title, action: action, active: false)
        item.accessibilityIdentifier = accessibilityIdentifier
        item.cellIdentifier = HLProfileCell.hl_reuseIdentifier()

        return item
    }

    func checkboxItemWithTitle(_ title: String, action: @escaping (ProfileItemAction), activeStateBlock: (ProfileItemActivateBlock)) -> HLProfileTableItem {
        let item = HLProfileTableItem(title: title, action: action, active: activeStateBlock())
        item.cellIdentifier = HLProfileSelectableCell.hl_reuseIdentifier()

        return item
    }

}
