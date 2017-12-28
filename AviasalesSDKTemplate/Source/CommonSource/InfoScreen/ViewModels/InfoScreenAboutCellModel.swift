//
//  InfoScreenAboutCellModel.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 17.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

struct InfoScreenAboutCellModel: InfoScreenCellModelProtocol, InfoScreenAboutCellProtocol {
    let type = InfoScreenCellModelType.about
    let icon: String
    let logo: String?
    let name: String?
    let description: String?
    let separator: Bool
}
