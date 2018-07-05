//
//  JRSDKPrice+Format.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 28.05.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

extension JRSDKPrice {

    @objc func formattedPriceinUserCurrency() -> String {
        let price = AviasalesNumberUtil.formatPrice(priceInUserCurrency()) ?? ""
        return price.arabicDigits().rtlStringIfNeeded()
    }
}
