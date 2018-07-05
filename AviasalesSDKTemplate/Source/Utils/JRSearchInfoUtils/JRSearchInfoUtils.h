//
//  JRSearchInfoUtils.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>

@interface JRSearchInfoUtils : NSObject

+ (NSArray *)getDirectionIATAsForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSArray *)getMainIATAsForSearchInfo:(JRSDKSearchInfo *)searchInfo;

+ (NSArray *)datesForSearchInfo:(JRSDKSearchInfo *)searchInfo;

+ (NSString *)shortDirectionIATAStringForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)fullDirectionIATAStringForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)fullDirectionCityStringForSearchInfo:(JRSDKSearchInfo *)searchInfo;

+ (NSString *)datesIntervalStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)passengersCountStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)travelClassStringWithTravelClass:(JRSDKTravelClass)travelClass;

+ (NSString *)formattedIatasForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)formattedDatesForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)formattedDatesExcludeYearComponentForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)formattedIatasAndDatesForSearchInfo:(JRSDKSearchInfo *)searchInfo;
+ (NSString *)formattedIatasAndDatesExcludeYearComponentForSearchInfo:(JRSDKSearchInfo *)searchInfo;

@end
