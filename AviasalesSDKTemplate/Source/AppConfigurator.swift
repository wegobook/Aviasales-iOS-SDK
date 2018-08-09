//
//  AppConfigurator.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 22.11.2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import Foundation
import Appodeal

@objcMembers
class AppConfigurator: NSObject {

    static func configure() {
        configureAviasalesSDK()
        configureAppodeal()
    }
}

private extension AppConfigurator {

    static func configureAviasalesSDK() {

        let token = ConfigManager.shared.apiToken
        let marker = ConfigManager.shared.partnerMarker
        let locale = Locale.current.identifier

        let configuration = AviasalesSDKInitialConfiguration(apiToken: token, apiLocale: locale, partnerMarker: marker)

        AviasalesSDK.setup(with: configuration)
    }

    static func configureAppodeal() {
        Appodeal.initialize(withApiKey: ConfigManager.shared.appodealKey, types: .interstitial)
    }
}
