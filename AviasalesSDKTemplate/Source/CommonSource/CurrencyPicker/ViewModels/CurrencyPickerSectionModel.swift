//
//  CurrencyPickerSectionModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 14.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct CurrencyPickerSectionModel {

    let cellModels: [CurrencyPickerCellModel]

    init(currencies: [HDKCurrency], selectedCurrency: HDKCurrency) {
        cellModels = currencies.map { CurrencyPickerCellModel(currency: $0, selectedCurrency: selectedCurrency) }
    }
}
