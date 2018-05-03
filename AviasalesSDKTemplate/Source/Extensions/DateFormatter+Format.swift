//
//  DateFormatter+Format.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 02.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

extension DateFormatter {

    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
