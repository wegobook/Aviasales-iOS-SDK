//
//  ASTPassengersPickerViewModel.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

enum ASTPassengersPickerCellModelType {
    case adults
    case children
    case infants
}

protocol ASTPassengersPickerCellModelProtocol {
    var type: ASTPassengersPickerCellModelType { get }
}

struct ASTPassengersPickerCellModel: ASTPassengersPickerCellModelProtocol {

    let type: ASTPassengersPickerCellModelType

    let title: String
    let subtitle: String
    let count: String
    let plusEnabled: Bool
    let minusEnabled: Bool
}

struct ASTPassengersPickerViewModel {

    let cellModels: [ASTPassengersPickerCellModelProtocol]
}
