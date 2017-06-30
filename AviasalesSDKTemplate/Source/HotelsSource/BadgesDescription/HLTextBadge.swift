//
//  HLTextBadge.swift
//  HotelLook
//
//  Created by Yegor Ivanov on 21/03/2017.
//
//

import UIKit

class HLTextBadge: HLPopularHotelBadge {
    init(name: String, systemName: String, color: UIColor) {
        super.init()
        self.name = name
        self.systemName = systemName
        self.color = color
    }
}
