//
//  NumberUtils.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 26.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

class NumberUtils {

    static func formattedPrice(currency: String, rubValue: NSNumber?) -> String? {
        guard let value = AviasalesNumberUtil.convertPrice(rubValue, fromCurrency: "RUB", to: currency) else {
            return nil
        }
        return AviasalesNumberUtil.formatPrice(value)
    }
}
