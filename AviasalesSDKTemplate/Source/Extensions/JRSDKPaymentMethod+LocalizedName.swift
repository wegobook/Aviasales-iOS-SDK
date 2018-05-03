//
//  JRSDKPaymentMethod+LocalizedName.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

@objc extension JRSDKPaymentMethod {

    var localizedName: String {

        switch name {
        case "exp":
            return NSLS("JR_FILTER_PAYMENT_METHOD_EXP")
        case "euroset":
            return NSLS("JR_FILTER_PAYMENT_METHOD_EUROSET")
        case "cash":
            return NSLS("JR_FILTER_PAYMENT_METHOD_CASH")
        case "card":
            return NSLS("JR_FILTER_PAYMENT_METHOD_CARD")
        case "yandex_money":
            return NSLS("JR_FILTER_PAYMENT_METHOD_YANDEX_MONEY")
        case "web_money":
            return NSLS("JR_FILTER_PAYMENT_METHOD_WEBMONEY")
        case "terminal":
            return NSLS("JR_FILTER_PAYMENT_METHOD_TERMINAL")
        case "svyaznoy":
            return NSLS("JR_FILTER_PAYMENT_METHOD_SVYAZNOY")
        case "elexnet":
            return NSLS("JR_FILTER_PAYMENT_METHOD_ELEXNET")
        case "bank":
            return NSLS("JR_FILTER_PAYMENT_METHOD_BANK")
        case "contact":
            return NSLS("JR_FILTER_PAYMENT_METHOD_CONTACT")
        case "credit":
            return NSLS("JR_FILTER_PAYMENT_METHOD_CREDIT")
        default:
            return name
        }
    }
}
