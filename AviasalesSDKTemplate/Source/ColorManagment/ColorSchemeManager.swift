//
//  ColorSchemeManager.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 17.11.2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import Foundation

@objcMembers
class ColorSchemeManager: NSObject {
    
    static let shared = ColorSchemeManager()
    
    var current: ColorScheme = BlueColorScheme()
}
