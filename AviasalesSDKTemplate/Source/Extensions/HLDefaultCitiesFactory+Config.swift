//
//  HLDefaultCitiesFactory+Config.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 05.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

extension HLDefaultCitiesFactory {

    static func configCity() -> HDKCity? {

        guard let id = ConfigManager.shared.hotelsCityID, let name = ConfigManager.shared.hotelsCityName, !id.isEmpty, !name.isEmpty else {
            return nil
        }

        return HDKCity(cityId: id,
                       name: name,
                       latinName: nil,
                       fullName: nil,
                       countryName: nil,
                       countryLatinName: nil,
                       countryCode: nil,
                       state: nil,
                       latitude: 0,
                       longitude: 0,
                       hotelsCount: 0,
                       cityCode: nil,
                       points: [],
                       seasons: [])
    }
}
