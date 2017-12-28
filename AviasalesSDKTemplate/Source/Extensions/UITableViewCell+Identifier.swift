//
//  UITableViewCell+Identifier.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 04.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

extension UITableViewCell {

    static var identifier: String {
        return String(describing: self)
    }
}
