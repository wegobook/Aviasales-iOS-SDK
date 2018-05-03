//
//  PriceCalendarManager.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 02.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

class PriceCalendarManager: NSObject {

    static let shared = PriceCalendarManager()

    private (set) var loader: JRSDKPriceCalendarLoader?
    private (set) var currency = CurrencyManager.shared.currency

    func prepareLoader(with searchInfo: JRSDKSearchInfo) {
        loader = JRSDKPriceCalendarLoader(searchInfo: searchInfo, delegate: nil)
        currency = CurrencyManager.shared.currency
    }
}
