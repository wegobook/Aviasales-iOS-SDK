//
//  CurrencyPickerPresenter.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 11.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

protocol CurrencyPickerViewProtocol: class {

    func set(sectionModels: [CurrencyPickerSectionModel])
    func update(sectionModels: [CurrencyPickerSectionModel])
    func showCurrencyAlert()
}

class CurrencyPickerPresenter {

    private let selection: () -> Void

    private weak var view: CurrencyPickerViewProtocol?

    fileprivate var mainCurrencies = [HDKCurrency]()
    fileprivate var otherCurrencies = [HDKCurrency]()

    fileprivate var selectedCurrency: HDKCurrency {
        set {
            CurrencyManager.shared.currency = newValue
        }
        get {
            return CurrencyManager.shared.currency
        }
    }

    fileprivate var filter: (HDKCurrency) -> Bool = { (_) -> Bool in
        return true
    }

    init(selection: @escaping () -> Void) {
        self.selection = selection
    }

    func attach(_ view: CurrencyPickerViewProtocol) {
        self.view = view
        prepareCurrencies()
        view.set(sectionModels: buildSectionModels())
    }

    func search(_ text: String) {

        filter = {
            if text.isEmpty {
                return true
            }
            if $0.code.lowercased().contains(text.lowercased()) ||  $0.text.lowercased().contains(text.lowercased()) {
                return true
            }
            return false
        }

        view?.set(sectionModels: buildSectionModels())
    }

    func select(_ cellModel: CurrencyPickerCellModel) {
        if cellModel.currency != selectedCurrency {
            selectedCurrency = cellModel.currency
            selection()
            view?.update(sectionModels: buildSectionModels())
            view?.showCurrencyAlert()
        }
    }
}

private extension CurrencyPickerPresenter {

    func prepareCurrencies() {

        let availableCurrencies = CurrencyManager.availableCurrencies

        mainCurrencies = prepareMainCurrencies(from: availableCurrencies)

        otherCurrencies = availableCurrencies.filter { !mainCurrencies.contains($0) }
    }

    func prepareMainCurrencies(from availableCurrencies: [HDKCurrency]) -> [HDKCurrency] {

        var codes = ["USD", "EUR"]

        if let local = Locale.current.currencyCode {
            codes.removeObject(local)
            codes.insert(local, at: 0)
        }

        var currencies = [HDKCurrency]()

        for code in codes {
            if let currency = availableCurrencies.first(where: { $0.code == code }) {
                currencies.append(currency)
            }
        }

        return currencies
    }
}

private extension CurrencyPickerPresenter {

    func buildSectionModels() -> [CurrencyPickerSectionModel] {

        var sectionModels = [CurrencyPickerSectionModel]()

        let filteredMainCurrencies = mainCurrencies.filter(filter)
        if filteredMainCurrencies.count > 0 {
            sectionModels.append(CurrencyPickerSectionModel(currencies: filteredMainCurrencies, selectedCurrency: selectedCurrency))
        }

        let filteredOtherCurrencies = otherCurrencies.filter(filter)
        if filteredOtherCurrencies.count > 0 {
            sectionModels.append(CurrencyPickerSectionModel(currencies: filteredOtherCurrencies, selectedCurrency: selectedCurrency))
        }

        return sectionModels
    }
}
