class CurrencySection: GroupedTableSection {
    let currencies: [HDKCurrency]

    init(title: String?, currencies: [HDKCurrency]) {
        self.currencies = currencies
        super.init(title: title, items: currencies)
    }
}
