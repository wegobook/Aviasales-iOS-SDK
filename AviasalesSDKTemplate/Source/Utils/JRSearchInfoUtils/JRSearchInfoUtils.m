//
//  JRSearchInfoUtils.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchInfoUtils.h"
#import "DateUtil.h"


static NSString *formattedDate(NSDate *date, BOOL includeMonth, BOOL includeYear, BOOL numberRepresentation);

@implementation JRSearchInfoUtils

+ (NSArray *)getDirectionIATAsForSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSMutableArray *iatas = [NSMutableArray new];
	for (JRSDKTravelSegment *travelSegment in searchInfo.travelSegments) {
		NSString *originIATA = travelSegment.originAirport.iata;
		if (originIATA) {
			[iatas addObject:originIATA];
		}
		NSString *destinationIATA = travelSegment.destinationAirport.iata;
		if (destinationIATA) {
			[iatas addObject:destinationIATA];
		}
	}
	if ([JRSDKModelUtils searchInfoIsDirectReturnFlight:searchInfo] && iatas.count > 2) {
		NSArray *directReturnIATAs = nil;
		NSRange directReturnIATAsRange = NSMakeRange(0, 2);
		directReturnIATAs = [iatas subarrayWithRange:directReturnIATAsRange];
		return directReturnIATAs;
	} else {
		return iatas;
	}
}

+ (NSArray *)getMainIATAsForSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSMutableArray *iatasForSearchInfo = [[self getDirectionIATAsForSearchInfo:searchInfo] mutableCopy];
	NSMutableArray *mainIATAsForSearchInfo = [NSMutableArray new];
	for (NSString *iata in iatasForSearchInfo) {
		NSString *mainIATA = [[[AviasalesSDK sharedInstance] airportsStorage] mainIATAByIATA:iata];
		if (mainIATA) {
			[mainIATAsForSearchInfo addObject:mainIATA];
		}
	}
	return mainIATAsForSearchInfo;
}

+ (NSArray *)datesForSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSMutableArray *dates = [NSMutableArray new];
    
	for (JRSDKTravelSegment *travelSegment in searchInfo.travelSegments) {
		NSDate *departureDate = travelSegment.departureDate;
		if (departureDate) {
			[dates addObject:departureDate];
		}
	}
	return dates;
}

+ (NSString *)shortDirectionIATAStringForSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSArray *iatas = [self getDirectionIATAsForSearchInfo:searchInfo];
    
    NSString *separator = [JRSDKModelUtils searchInfoIsComplex:searchInfo] ? @" … " : @" — ";
	return [NSString stringWithFormat:@"%@ %@ %@", iatas.firstObject, separator, iatas.lastObject];
}

+ (NSString *)fullDirectionIATAStringForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    NSMutableString *directionString = [NSMutableString new];
    for (JRSDKTravelSegment *travelSegment in searchInfo.travelSegments) {
        if (travelSegment != searchInfo.travelSegments.firstObject) {
            [directionString appendString:@"  "];
        }
        [directionString appendFormat:@"%@—%@", travelSegment.originAirport.iata, travelSegment.destinationAirport.iata];
    }
	return directionString;
}

+ (NSString *)fullDirectionCityStringForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    NSArray *iatas = [self getDirectionIATAsForSearchInfo:searchInfo];
    NSMutableString *directionString = [NSMutableString new];
	for (NSInteger i = 0; i < iatas.count; i++) {
		NSString *iata = iatas[i];
        JRSDKAirport *airport = [[[AviasalesSDK sharedInstance] airportsStorage] findAnythingByIATA:iata];
        NSString *airportCity = airport.city ? airport.city : iata;
		[directionString appendString:airportCity];
		if (i != iatas.count - 1) {
			[directionString appendString:@" — "];
		}
	}
	return directionString;
}

+ (NSString *)datesIntervalStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSString *datesString;
    
	NSDate *firstDate = [searchInfo.travelSegments.firstObject departureDate];
	NSDate *lastDate = searchInfo.travelSegments.count > 1 ?[searchInfo.travelSegments.lastObject departureDate] : nil;
    
	if (lastDate) {
		datesString = [NSString stringWithFormat:@"%@ — %@", iPhone() ?[DateUtil dayMonthStringFromDate:firstDate] : [DateUtil dayFullMonthYearStringFromDate:firstDate], iPhone() ?[DateUtil dayMonthStringFromDate:lastDate] : [DateUtil dayFullMonthYearStringFromDate:lastDate]];
	} else {
		datesString = [NSString stringWithFormat:@"%@", iPhone() ?[DateUtil dayFullMonthStringFromDate:firstDate] : [DateUtil dayFullMonthYearStringFromDate:firstDate]];
	}
	return datesString;
}

+ (NSString *)passengersCountStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo {
	NSInteger passengers = searchInfo.adults + searchInfo.children  + searchInfo.infants;
    NSString *format = NSLSP(@"JR_SEARCHINFO_PASSENGERS", passengers);
	return [NSString stringWithFormat:format, passengers];
}

+ (NSString *)travelClassStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo {
    return [self travelClassStringWithTravelClass:searchInfo.travelClass];
}

+ (NSString *)travelClassStringWithTravelClass:(JRSDKTravelClass)travelClass {
    switch (travelClass) {
        case JRSDKTravelClassBusiness : {
            return NSLS(@"JR_SEARCHINFO_BUSINESS");
        } break;
        case JRSDKTravelClassPremiumEconomy : {
            return NSLS(@"JR_SEARCHINFO_PREMIUM_ECONOMY");
        } break;
        case JRSDKTravelClassFirst : {
            return NSLS(@"JR_SEARCHINFO_FIRST");
        } break;
        default : {
            return NSLS(@"JR_SEARCHINFO_ECONOMY");
        } break;
    }
}

+ (NSString *)formattedIatasForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    NSMutableArray *const iatas = [NSMutableArray array];
    for (JRSDKTravelSegment *travelSegment in searchInfo.travelSegments) {
        [iatas addObject:travelSegment.originAirport.iata];
    }
    JRSDKIATA const lastIata = searchInfo.travelSegments.lastObject.destinationAirport.iata;
    if (![iatas[0] isEqualToString:lastIata]) {
        [iatas addObject:lastIata];
    }
    NSString *format = iatas.count > 2 ? @"%@ – … –  %@" : @"%@ — %@";
    return [[NSString stringWithFormat:[format formatAccordingToTextDirection], iatas.firstObject, iatas.lastObject] rtlStringIfNeeded];
}

+ (NSString *)formattedDatesForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    JRSDKTravelSegment *const firstTravelSegment = searchInfo.travelSegments.firstObject;
    if (firstTravelSegment.departureDate == nil) {
        return nil;
    }

    NSCalendar *const calendar = [NSCalendar currentCalendar];
    const NSCalendarUnit necessaryDateComponents = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *const departureDateComponents = [calendar components:necessaryDateComponents fromDate:firstTravelSegment.departureDate];
    NSDateComponents *const currentYear = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];

    if (searchInfo.travelSegments.count == 1) {
        return formattedDate(firstTravelSegment.departureDate, YES, departureDateComponents.year != currentYear.year, NO);
    }

    JRSDKTravelSegment *const lastTravelSegment = searchInfo.travelSegments.lastObject;

    NSDateComponents *const returnDateComponents = [calendar components:necessaryDateComponents fromDate:lastTravelSegment.departureDate];

    BOOL departureIncludeYear = NO;
    BOOL returnIncludeYear = returnDateComponents.year != currentYear.year;

    if (returnDateComponents.year != departureDateComponents.year) {
        departureIncludeYear = YES;
        returnIncludeYear = YES;
    }
    const BOOL numberRepresentation = searchInfo.travelSegments.count > 2;

    NSString *const formattedDeparture = formattedDate(firstTravelSegment.departureDate, YES, departureIncludeYear, numberRepresentation);
    NSString *const formattedReturn = formattedDate(lastTravelSegment.departureDate, YES, returnIncludeYear, numberRepresentation);

    return [NSString stringWithFormat:@"%@%@%@", formattedDeparture, @" - ", formattedReturn];
}

+ (NSString *)formattedDatesExcludeYearComponentForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    JRSDKTravelSegment *const firstTravelSegment = searchInfo.travelSegments.firstObject;
    if (firstTravelSegment.departureDate == nil) {
        return nil;
    }

    if (searchInfo.travelSegments.count == 1) {
        return formattedDate(firstTravelSegment.departureDate, YES, NO, NO);
    }

    JRSDKTravelSegment *const lastTravelSegment = searchInfo.travelSegments.lastObject;

    NSString *const formattedDeparture = formattedDate(firstTravelSegment.departureDate, YES, NO, NO);
    NSString *const formattedReturn = formattedDate(lastTravelSegment.departureDate, YES, NO, NO);

    return [NSString stringWithFormat:@"%@%@%@", formattedDeparture, @" - ", formattedReturn];
}

+ (NSString *)formattedIatasAndDatesForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    NSString *formattedIatas = [self formattedIatasForSearchInfo:searchInfo];
    NSString *formattedDates = [self formattedDatesForSearchInfo:searchInfo];
    return [NSString stringWithFormat:@"%@%@%@", formattedIatas, NSLS(@"COMMA_AND_WHITESPACE"), formattedDates];
}

+ (NSString *)formattedIatasAndDatesExcludeYearComponentForSearchInfo:(JRSDKSearchInfo *)searchInfo {
    NSString *formattedIatas = [self formattedIatasForSearchInfo:searchInfo];
    NSString *formattedDates = [self formattedDatesExcludeYearComponentForSearchInfo:searchInfo];
    return [NSString stringWithFormat:@"%@%@%@", formattedIatas, NSLS(@"COMMA_AND_WHITESPACE"), formattedDates];
}

@end

static NSString *formattedDate(NSDate *date, BOOL includeMonth, BOOL includeYear, BOOL numberRepresentation) {
    NSString *format;
    if (numberRepresentation) {
        format = @"d.MM";
    } else {
        if (includeMonth && includeYear) {
            format = @"d MMM yyyy";
        } else if (includeMonth) {
            format = @"d MMM";
        } else {
            format = @"d";
        }
    }

    NSDateFormatter *const formatter = [NSDateFormatter applicationUIDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:format options:kNilOptions locale:formatter.locale];
    return [[[formatter stringFromDate:date] arabicDigits] rtlStringIfNeeded];
}
