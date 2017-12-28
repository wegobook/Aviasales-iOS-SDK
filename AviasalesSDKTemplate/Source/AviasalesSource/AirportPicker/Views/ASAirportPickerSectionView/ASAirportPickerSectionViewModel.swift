//
//  ASAirportPickerSectionViewModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 06.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

enum ASAirportPickerCellModelType {
    case info
    case data
}

protocol ASAirportPickerCellModelProtocol {
    var type: ASAirportPickerCellModelType { get }
}

struct ASAirportPickerSectionViewModel: ASAirportPickerSectionViewProtocol {
    let name: String?
    let cellModels: [ASAirportPickerCellModelProtocol]
}
