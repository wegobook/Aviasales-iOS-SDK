//
//  ASAirportPickerDataCellModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 03.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct ASAirportPickerDataCellModel: ASAirportPickerCellModelProtocol, ASAirportPickerDataCellProtocol {
    let type = ASAirportPickerCellModelType.data
    let city: String?
    let airport: String?
    let iata: String
    let model: JRSDKAirport
}
