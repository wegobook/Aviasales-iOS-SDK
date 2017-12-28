//
//  InfoScreenCellModelProtocol.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 17.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

enum InfoScreenCellModelType {
    case about
    case rate
    case currency
    case email
    case external
    case version
}

protocol InfoScreenCellModelProtocol {
    var type: InfoScreenCellModelType { get }
}
