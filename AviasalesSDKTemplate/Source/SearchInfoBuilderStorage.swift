//
//  SearchInfoBuilderStorage.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 08.03.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import Foundation

@objcMembers
class SearchInfoBuilderStorage: NSObject {

    private enum StorageKey: String {
        case simpleSearchInfoBuilderStorageKey
        case complexSearchInfoBuilderStorageKey
    }

    static let shared = SearchInfoBuilderStorage()

    var updateCallback: (() -> ())?

    var simpleSearchInfoBuilder: JRSDKSearchInfoBuilder {
        get {
            return searchInfoBuilder(for: .simpleSearchInfoBuilderStorageKey)
        }
        set{
            set(searchInfoBuilder: newValue, for: .simpleSearchInfoBuilderStorageKey)
        }
    }

    var complexSearchInfoBuilder: JRSDKSearchInfoBuilder {
        get {
            return searchInfoBuilder(for: .complexSearchInfoBuilderStorageKey)
        }
        set {
            set(searchInfoBuilder: newValue, for: .complexSearchInfoBuilderStorageKey)
        }
    }

    func updateStorage(simpleSearchInfo: JRSDKSearchInfo) {
        let searchInfoBuilder = JRSDKSearchInfoBuilder(searchInfoToCopy: simpleSearchInfo)
        simpleSearchInfoBuilder = searchInfoBuilder
        updateCallback?()
    }

    private func searchInfoBuilder(for key: StorageKey) -> JRSDKSearchInfoBuilder {
        if let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data, let searchInfoBuilder = NSKeyedUnarchiver.unarchiveObject(with: data) as? JRSDKSearchInfoBuilder {
            return searchInfoBuilder
        } else {
            let searchInfoBuilder = JRSDKSearchInfoBuilder()
            searchInfoBuilder.adults = 1
            searchInfoBuilder.travelSegments = JRSDKSearchInfoBuilder.buildTravelSegmentsBasedOnConfig()
            return searchInfoBuilder
        }
    }

    private func set(searchInfoBuilder: JRSDKSearchInfoBuilder, for key: StorageKey) {
        let data = NSKeyedArchiver.archivedData(withRootObject: searchInfoBuilder)
        UserDefaults.standard.set(data, forKey: key.rawValue)
    }
}
