//
//  AppConfigurator.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 22.11.2017.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import Foundation

class AppConfigurator: NSObject {

    static func configure() {
        configureAviasalesSDK()
        configureAdvertisementManager()
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

    static func configureAdvertisementManager() {

        if !ConfigManager.shared.appodealKey.isEmpty {
            JRAdvertisementManager.sharedInstance().initializeAppodeal(withAPIKey: ConfigManager.shared.appodealKey, testingEnabled: true)
        }
    }
}
