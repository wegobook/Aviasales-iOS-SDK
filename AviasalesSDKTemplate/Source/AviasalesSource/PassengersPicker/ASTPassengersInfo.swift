//
//  ASTPassengersInfo.swift
//  AviasalesSDKTemplate
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

@objcMembers
class ASTPassengersInfo: NSObject {

    let adults: Int
    let children: Int
    let infants: Int
    let travelClass: JRSDKTravelClass

    init(adults: Int, children: Int, infants: Int, travelClass: JRSDKTravelClass) {
        self.adults = adults
        self.children = children
        self.infants = infants
        self.travelClass = travelClass
        super.init()
    }
}
