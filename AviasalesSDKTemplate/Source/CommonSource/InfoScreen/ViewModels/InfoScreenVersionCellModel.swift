//
//  InfoScreenVersionCellModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 20.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct InfoScreenVersionCellModel: InfoScreenCellModelProtocol, InfoScreenVersionCellProtocol {
    let type = InfoScreenCellModelType.version
    let version: String?
}
