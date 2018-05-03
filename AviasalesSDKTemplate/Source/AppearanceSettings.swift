//
//  AppearanceSettings.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 02.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class AppearanceSettings: NSObject {

    static func setup() {

        UINavigationBar.appearance().barStyle = .black

        UISwitch.appearance().onTintColor = JRColorScheme.mainColor()

        UITableView.appearance().backgroundColor = JRColorScheme.mainBackgroundColor()
        
        UICollectionView.appearance().backgroundColor = JRColorScheme.mainBackgroundColor()
    }
}
