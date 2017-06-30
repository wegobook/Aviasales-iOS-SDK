import HotellookSDK

class CurrencyManager: NSObject {

    static let shared = CurrencyManager()

    let store = CurrencyStore()

    func getCurrency(withCode code: String) -> HDKCurrency? {
        return allCurrencies().first(where: { (currency) -> Bool in currency.code == code })
    }

    func localeCurrencies() -> [HDKCurrency] {
        return store.currencyInfo.localeCurrencies
    }

    func otherCurrencies() -> [HDKCurrency] {
        return store.currencyInfo.otherCurrencies
    }

    fileprivate func allCurrencies() -> [HDKCurrency] {
        return localeCurrencies() + otherCurrencies()
    }

    func defaultCurrency() -> HDKCurrency {
        return getCurrency(withCode: "USD") ?? HDKCurrency(code: "USD", symbol: "$", text: "US Dollar")
    }

    func updateCurrencies() {
        let api = ServiceLocator.shared.api
        api.currencies().promise().then { currencyInfo in
            self.store.saveCurrencies(currencyInfo)
        }.catch {_ in
            // Ignore errors
        }
    }

}
