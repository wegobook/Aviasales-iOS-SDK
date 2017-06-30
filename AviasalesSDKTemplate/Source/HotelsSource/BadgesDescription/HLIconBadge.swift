//
//  HLIconBadge.swift
//  HotelLook
//
//  Created by Yegor Ivanov on 21/03/2017.
//
//

import UIKit

class HLIconBadge: HLPopularHotelBadge {
    var imageName: String?
    init(imageName: String, systemName: String, color: UIColor) {
        super.init()
        self.imageName = imageName
        self.systemName = systemName
        self.color = color
    }
}
