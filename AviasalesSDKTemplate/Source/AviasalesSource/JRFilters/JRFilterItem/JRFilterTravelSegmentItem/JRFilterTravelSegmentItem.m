//
//  JRFilterTravelSegmentItem.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterTravelSegmentItem.h"

#import "DateUtil.h"


@interface JRFilterTravelSegmentItem ()

@end


@implementation JRFilterTravelSegmentItem

- (instancetype)initWithTravelSegment:(JRSDKTravelSegment *)travelSegment {
    self = [super init];
    if (self) {
        _travelSegment = travelSegment;
    }
    
    return self;
}

#pragma - mark JRFilterItemProtocol

- (NSString *)title {
    return [NSString stringWithFormat:[@"%@ – %@" formatAccordingToTextDirection], self.travelSegment.originAirport.iata, self.travelSegment.destinationAirport.iata];
}

- (NSString *)detailsTitle {
    return [[DateUtil fullDayMonthYearWeekdayStringFromDate:self.travelSegment.departureDate] arabicDigits];
}

- (NSAttributedString *)attributedStringValue {
    return [[NSAttributedString alloc] initWithString:@""];
}

@end
