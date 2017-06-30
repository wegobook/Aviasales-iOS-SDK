//
//  JRFilterTravelSegmentBounds.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>

@interface JRFilterTravelSegmentBounds : NSObject

@property (strong, nonatomic) JRSDKTravelSegment *travelSegment;

@property (assign, nonatomic) BOOL transferToAnotherAirport;
@property (assign, nonatomic) BOOL filterTransferToAnotherAirport;

@property (assign, nonatomic) BOOL overnightStopover;
@property (assign, nonatomic) BOOL filterOvernightStopover;

@property (assign, nonatomic) NSTimeInterval maxDepartureTime;
@property (assign, nonatomic) NSTimeInterval minDepartureTime;
@property (assign, nonatomic) NSTimeInterval minFilterDepartureTime;
@property (assign, nonatomic) NSTimeInterval maxFilterDepartureTime;

@property (assign, nonatomic) NSTimeInterval maxArrivalTime;
@property (assign, nonatomic) NSTimeInterval minArrivalTime;
@property (assign, nonatomic) NSTimeInterval minFilterArrivalTime;
@property (assign, nonatomic) NSTimeInterval maxFilterArrivalTime;

@property (assign, nonatomic) JRSDKFlightDuration maxDelaysDuration;
@property (assign, nonatomic) JRSDKFlightDuration minDelaysDuration;
@property (assign, nonatomic) JRSDKFlightDuration minFilterDelaysDuration;
@property (assign, nonatomic) JRSDKFlightDuration maxFilterDelaysDuration;

@property (assign, nonatomic) JRSDKFlightDuration maxTotalDuration;
@property (assign, nonatomic) JRSDKFlightDuration minTotalDuration;
@property (assign, nonatomic) JRSDKFlightDuration filterTotalDuration;

@property (strong, nonatomic) NSOrderedSet<NSNumber *> *transfersCounts;
@property (strong, nonatomic) NSOrderedSet<NSNumber *> *filterTransfersCounts;

@property (strong, nonatomic) NSOrderedSet<JRSDKAirline *> *airlines;
@property (strong, nonatomic) NSOrderedSet<JRSDKAirline *> *filterAirlines;

@property (strong, nonatomic) NSOrderedSet<JRSDKAlliance *> *alliances;
@property (strong, nonatomic) NSOrderedSet<JRSDKAlliance *> *filterAlliances;

@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *originAirports;
@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *filterOriginAirports;

@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *stopoverAirports;
@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *filterStopoverAirports;

@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *destinationAirports;
@property (strong, nonatomic) NSOrderedSet<JRSDKAirport *> *filterDestinationAirports;

@property (strong, nonatomic) NSDictionary<NSNumber *, NSNumber *> *transfersCountsWitnMinPrice;

@property (assign, nonatomic, readonly) BOOL isReset;

- (instancetype)initWithTravelSegment:(JRSDKTravelSegment *)travelSegment;

- (void)resetBounds;

@end
