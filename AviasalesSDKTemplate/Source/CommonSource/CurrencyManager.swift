//
//  CurrencyManager.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 04.10.2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

private let currencyKey = "currencyKey"

@objcMembers
class CurrencyManager: NSObject {

    static let shared = CurrencyManager()

    static private let locale = NSLocale.applicationUI() ?? NSLocale.current

    static let availableCurrencies = availableCurrencyCodes().sorted().map { buildCurrency(from: $0) }

    var currency: HDKCurrency = CurrencyManager.restoreCurrency() ?? CurrencyManager.defaultCurrency() {
        didSet {
            saveCurrency()
        }
    }


    fileprivate static let shouldHandleBYN: Bool = {
        if #available(iOS 11, *) {
            return false
        } else {
            return true
        }
    }()
}

private extension CurrencyManager {

    static func availableCurrencyCodes() -> [String] {

        let resource = "available_currency_codes"

        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            fatalError("\(resource) have not found")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("\(resource) have not been loaded")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            fatalError("\(resource) have not been serialized")
        }

        guard let array = json as? [String] else {
            fatalError("\(resource) have incorrect format")
        }

        return array
    }

    static func buildCurrency(from code: String) -> HDKCurrency {

        if code == "BYN" && shouldHandleBYN {
            let name = locale.localizedString(forCurrencyCode: "BYR") ?? String()
            return HDKCurrency(code: code, symbol: "BYN", text: name)
        } else {
            let symbol = (locale as NSLocale).displayName(forKey: .currencySymbol, value: code) ?? String()
            let name = locale.localizedString(forCurrencyCode: code) ?? String()
            return HDKCurrency(code: code, symbol: symbol, text: name)
        }
    }
}

private extension CurrencyManager {

    static func restoreCurrency() -> HDKCurrency? {
        guard let data = UserDefaults.standard.object(forKey: currencyKey) as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? HDKCurrency
    }

    static func defaultCurrency() -> HDKCurrency {

        if let configCode = ConfigManager.shared.defaultCurrency?.uppercased(), availableCurrencyCodes().contains(configCode) {
            return buildCurrency(from: configCode)
        }

        if let localCode = Locale.current.currencyCode, availableCurrencyCodes().contains(localCode) {
            return buildCurrency(from: localCode)
        }

        return buildCurrency(from: "USD")
    }

    func saveCurrency() {
        let data = NSKeyedArchiver.archivedData(withRootObject: currency)
        UserDefaults.standard.set(data, forKey: currencyKey)
    }
}
