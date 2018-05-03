//
//  SearchResultsCardItem.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 19.01.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

class SearchResultsCardItem: NSObject {
    let index: Int
    let view: UIView
    let height: CGFloat

    init(index: Int, view: UIView, height: CGFloat) {
        self.index = index
        self.view = view
        self.height = height
        super.init()
    }
}
