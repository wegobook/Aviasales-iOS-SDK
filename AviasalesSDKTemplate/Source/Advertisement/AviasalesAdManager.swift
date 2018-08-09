//
//  AviasalesAdManager.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 24.07.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

class AviasalesAdManager {

    static let shared = AviasalesAdManager()

    private (set) var cachedAdView: AviasalesSDKAdsView?

    func loadAdView(for searchInfo: JRSDKSearchInfo) {

        cachedAdView = nil

        AviasalesSDK.sharedInstance().adsManager.loadAdsViewForSearchResults(with: searchInfo) { [weak self] (adView, error) in
            self?.cachedAdView = adView
        }
    }
}
