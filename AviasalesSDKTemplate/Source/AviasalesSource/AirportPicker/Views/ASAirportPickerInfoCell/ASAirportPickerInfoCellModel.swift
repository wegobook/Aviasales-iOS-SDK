//
//  ASAirportPickerInfoCellModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 03.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct ASAirportPickerInfoCellModel: ASAirportPickerCellModelProtocol, ASAirportPickerInfoCellProtocol {
    let type = ASAirportPickerCellModelType.info
    let loading: Bool
    let info: String
}
