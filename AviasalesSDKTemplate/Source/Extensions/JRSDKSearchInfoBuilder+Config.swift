//
//  JRSDKSearchInfoBuilder+Config.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 01.09.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

extension JRSDKSearchInfoBuilder {

    static func buildTravelSegmentsBasedOnConfig() -> NSOrderedSet? {

        guard let origin = ConfigManager.shared.flightsOrigin, let destination = ConfigManager.shared.flightsDestination else {
            return nil
        }

        let airportsStorage = AviasalesSDK.sharedInstance().airportsStorage

        let travelSegmentBuilder = JRSDKTravelSegmentBuilder()

        travelSegmentBuilder.originAirport = airportsStorage.findAnything(byIATA: origin)
        travelSegmentBuilder.destinationAirport = airportsStorage.findAnything(byIATA: destination)
        travelSegmentBuilder.departureDate = DateUtil.nextWeekend()

        guard let travelSegment = travelSegmentBuilder.build() else {
            return nil
        }

        return NSOrderedSet(object: travelSegment)
    }
}
