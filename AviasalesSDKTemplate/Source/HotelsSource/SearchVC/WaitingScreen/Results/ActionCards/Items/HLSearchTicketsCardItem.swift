//
//  HLSearchTicketsCardItem.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 05/06/2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

class HLSearchTicketsCardItem: HLActionCardItem {

    override init(topItem: Bool, cellReuseIdentifier: String, filter: Filter?, delegate: HLActionCellDelegate?) {
        super.init(topItem: topItem, cellReuseIdentifier: cellReuseIdentifier, filter: filter, delegate: delegate)
        height = 76.0
    }
}
