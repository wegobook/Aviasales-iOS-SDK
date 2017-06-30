class HLCurrencyVC: ASTGroupedSearchVC {

    var filterText: String?

    var currencySections: [CurrencySection] {
        return sections as! [CurrencySection]
    }

    // MARK: - Private

    private func shouldIncludeCurrency(_ currency: HDKCurrency) -> Bool {
        guard let filter = filterText, filter.characters.count > 0 else { return true }
        if currency.code.uppercased().contains(filter) {
            return true
        }
        if currency.text.uppercased().contains(filter) {
            return true
        }

        return false
    }

    private func createSections() -> [CurrencySection] {
        var result: [CurrencySection] = []

        let localeCurrencies = CurrencyManager.shared.localeCurrencies().filter(shouldIncludeCurrency)
        if localeCurrencies.count > 0 {
            result.append(CurrencySection(title: nil, currencies: localeCurrencies))
        }

        let otherCurrencies = CurrencyManager.shared.otherCurrencies().filter(shouldIncludeCurrency)
        if otherCurrencies.count > 0 {
            result.append(CurrencySection(title: nil, currencies: otherCurrencies))
        }

        return result
    }

    // MARK: - Override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.hl_registerNib(withName: HLCurrencyTableCell.hl_reuseIdentifier())
        resultsTableController.tableView.hl_registerNib(withName: HLCurrencyTableCell.hl_reuseIdentifier())
        title = NSLS("HL_LOC_ABOUT_CURRENCY")
        searchController.searchBar.placeholder = NSLS("LOC_CURRENCY_SEARCH_PLACEHOLDER")
        resetTableContent()
    }

    override func resetTableContent() {
        super.resetTableContent()
        filterText = nil
        sections = createSections()
    }

    // MARK: - UITableViewDataSource and UITableViewDataSource methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency: HDKCurrency
        if tableView == self.tableView {
            currency = currencySections[indexPath.section].currencies[indexPath.row]
        } else {
            currency = (resultsTableController.sections as! [CurrencySection])[indexPath.section].currencies[indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: HLCurrencyTableCell.hl_reuseIdentifier(), for: indexPath) as! HLCurrencyTableCell
        cell.currency = currency
        cell.marked = (currency == InteractionManager.shared.currency)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HLCurrencyTableCell else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if !cell.marked {
            tableView.unmarkAllCells()
            cell.marked = true

            let newCurrency: HDKCurrency
            if tableView == self.tableView {
                newCurrency = currencySections[indexPath.section].currencies[indexPath.row]
            } else {
                newCurrency = (resultsTableController.sections as! [CurrencySection])[indexPath.section].currencies[indexPath.row]
            }

            let oldCurrency = InteractionManager.shared.currency
            if oldCurrency != newCurrency {
                showCurrencyAlert()
            }

            searchInfo?.currency = newCurrency
            InteractionManager.shared.currencySelected(newCurrency)
            goBack()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func showCurrencyAlert() {
        showAlert(title: NSLS("CHANGE_CURRENCY_ALERT_TITLE"),
                  message: NSLS("CHANGE_CURRENCY_ALERT_DESCRIPTION"),
                  cancelButtonTitle: NSLS("HL_LOC_ALERT_CLOSE_BUTTON"))
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterText = searchText.uppercased()
        resultsTableController.sections = createSections()
        resultsTableController.tableView.reloadData()
    }
}
