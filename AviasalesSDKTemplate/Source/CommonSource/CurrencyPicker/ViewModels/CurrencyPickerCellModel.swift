//
//  CurrencyPickerCellModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct CurrencyPickerCellModel: CurrencyCellModelProtocol {

    let currency: HDKCurrency
    let code: String
    let name: String
    let selected: Bool

    init(currency: HDKCurrency, selectedCurrency: HDKCurrency) {
        self.currency = currency
        self.code = currency.code
        self.name = currency.text
        self.selected = currency == selectedCurrency
    }
}
