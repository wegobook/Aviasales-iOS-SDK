import HotellookSDK

class CurrencyStore: NSObject {

    fileprivate (set) var currencyInfo: HDKCurrencyInfo

    let kUserDefaultsKey = "currencies_info"

    override init() {
        currencyInfo = HDKCurrencyInfo(otherCurrencies: CurrencyStore.defaultCurrencies())
        super.init()
        loadCurrencies()
    }

    func saveCurrencies(_ currencyInfo: HDKCurrencyInfo) {
        self.currencyInfo = currencyInfo
        HDKDefaultsSaver.saveObject(currencyInfo, forKey: kUserDefaultsKey)
    }

    func loadCurrencies() {
        if let currencyInfo = HDKDefaultsSaver.loadObjectWithKey(kUserDefaultsKey) as? HDKCurrencyInfo {
            self.currencyInfo = currencyInfo
        }
    }

    static func defaultCurrencies() -> [HDKCurrency] {
        return [HDKCurrency(code: "AUD", symbol: "A$", text: localizedCurrency("HL_LOC_CURRENCY_AUD")),
                HDKCurrency(code: "CAD", symbol: "C$", text: localizedCurrency("HL_LOC_CURRENCY_CAD")),
                HDKCurrency(code: "CHF", symbol: "CHF", text: localizedCurrency("HL_LOC_CURRENCY_CHF")),
                HDKCurrency(code: "CNY", symbol: "元", text: localizedCurrency("HL_LOC_CURRENCY_CNY")),
                HDKCurrency(code: "EUR", symbol: "€", text: localizedCurrency("HL_LOC_CURRENCY_EUR")),
                HDKCurrency(code: "GBP", symbol: "£", text: localizedCurrency("HL_LOC_CURRENCY_GBP")),
                HDKCurrency(code: "HKD", symbol: "HK$", text: localizedCurrency("HL_LOC_CURRENCY_HKD")),
                HDKCurrency(code: "INR", symbol: "₹", text: localizedCurrency("HL_LOC_CURRENCY_INR")),
                HDKCurrency(code: "JPY", symbol: "¥", text: localizedCurrency("HL_LOC_CURRENCY_JPY")),
                HDKCurrency(code: "NZD", symbol: "NZ$", text: localizedCurrency("HL_LOC_CURRENCY_NZD")),
                HDKCurrency(code: "RUB", symbol: "₽", text: localizedCurrency("HL_LOC_CURRENCY_RUB")),
                HDKCurrency(code: "SGD", symbol: "S$", text: localizedCurrency("HL_LOC_CURRENCY_SGD")),
                HDKCurrency(code: "UAH", symbol: "₴", text: localizedCurrency("HL_LOC_CURRENCY_UAH")),
                HDKCurrency(code: "USD", symbol: "$", text: localizedCurrency("HL_LOC_CURRENCY_USD")),
                HDKCurrency(code: "THB", symbol: "฿", text: localizedCurrency("HL_LOC_CURRENCY_THB")),
                HDKCurrency(code: "AED", symbol: "AED", text: localizedCurrency("HL_LOC_CURRENCY_AED")),
                HDKCurrency(code: "KRW", symbol: "₩", text: localizedCurrency("HL_LOC_CURRENCY_KRW")),
                HDKCurrency(code: "BRL", symbol: "R$", text: localizedCurrency("HL_LOC_CURRENCY_BRL")),
                HDKCurrency(code: "TWD", symbol: "NT$", text: localizedCurrency("HL_LOC_CURRENCY_TWD")),
                HDKCurrency(code: "MOP", symbol: "MOP$", text: localizedCurrency("HL_LOC_CURRENCY_MOP")),
                HDKCurrency(code: "BYN", symbol: "Br", text: localizedCurrency("HL_LOC_CURRENCY_BYN")),
                HDKCurrency(code: "AZN", symbol: "₼", text: localizedCurrency("HL_LOC_CURRENCY_AZN")),
                HDKCurrency(code: "IDR", symbol: "Rp", text: localizedCurrency("HL_LOC_CURRENCY_IDR")),
                HDKCurrency(code: "KZT", symbol: "₸", text: localizedCurrency("HL_LOC_CURRENCY_KZT")),
                HDKCurrency(code: "MYR", symbol: "RM", text: localizedCurrency("HL_LOC_CURRENCY_MYR")),
                HDKCurrency(code: "PLN", symbol: "zł", text: localizedCurrency("HL_LOC_CURRENCY_PLN")),
                HDKCurrency(code: "ZAR", symbol: "R", text: localizedCurrency("HL_LOC_CURRENCY_ZAR")),
                HDKCurrency(code: "PHP", symbol: "₱", text: localizedCurrency("HL_LOC_CURRENCY_PHP")),
                HDKCurrency(code: "VND", symbol: "₫", text: localizedCurrency("HL_LOC_CURRENCY_VND")),
                HDKCurrency(code: "ARS", symbol: "AR$", text: localizedCurrency("HL_LOC_CURRENCY_ARS")),
                HDKCurrency(code: "SAR", symbol: "﷼‎", text: localizedCurrency("HL_LOC_CURRENCY_SAR"))]
    }

    fileprivate static func localizedCurrency(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Currencies", comment: "")
    }
}
