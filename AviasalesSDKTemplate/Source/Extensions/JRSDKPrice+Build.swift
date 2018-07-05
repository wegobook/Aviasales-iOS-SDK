//
//  JRSDKPrice+Build.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 29.05.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

extension JRSDKPrice {

    @objc static func price(currency: String, value: Float) -> JRSDKPrice? {
        let builder = JRSDKPriceBuilder()
        builder.currency = currency
        builder.value = value
        return builder.build()
    }
}
