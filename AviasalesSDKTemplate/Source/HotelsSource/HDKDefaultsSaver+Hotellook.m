#import "HDKDefaultsSaver+Hotellook.h"
#import <HotellookSDK/HotellookSDK.h>

#define HL_MAX_RECENT_CITIES_COUNT 10
#define HL_MAX_RECENT_GOOGLE_POINTS 10
#define HL_MAX_RECENT_NAME_FILTERS_COUNT 10

NSString * const kRecentSelectedPoints = @"googleRecentSelectedPoints";
NSString * const kDefaultsLastSelectedCities = @"lastSelectedCities";
NSString * const kDefaultsLastSelectedNameFilters = @"lastSelectedNameFilters";


@implementation HDKDefaultsSaver (HL)

+ (NSArray *)getRecentSearchDestinations
{
    NSArray *recentDestinations = nil;
    @try {
        recentDestinations = [self loadObjectWithKey:kDefaultsLastSelectedCities];
    }
    @catch (NSException *exception) {
    }
    return recentDestinations;
}

+ (void)addRecentSearchDestination:(id)object
{
    NSMutableArray *newRecentSearchDestinations = [[self getRecentSearchDestinations] mutableCopy] ?: [NSMutableArray new];

    if ([newRecentSearchDestinations containsObject:object]) {
        [newRecentSearchDestinations removeObject:object];
    }

    [newRecentSearchDestinations insertObject:object atIndex:0];

    NSArray *result = [newRecentSearchDestinations subarrayWithRange:NSMakeRange(0, MIN(HL_MAX_RECENT_CITIES_COUNT, newRecentSearchDestinations.count))];
    [self saveObject:result forKey:kDefaultsLastSelectedCities];
}

+ (NSArray *) getRecentSelectedNameFilter
{
    return [self loadObjectWithKey:kDefaultsLastSelectedNameFilters];
}

+ (void)addRecentSelectedNameFilter:(id)object
{
    NSMutableArray *newFilters = [[self getRecentSelectedNameFilter] mutableCopy];
    if (newFilters == nil) {
        newFilters = [NSMutableArray new];
    }

    if ([newFilters containsObject:object]) {
        [newFilters removeObject:object];
    }

    [newFilters insertObject:object atIndex:0];

    NSArray *result = [newFilters subarrayWithRange:NSMakeRange(0, MIN(HL_MAX_RECENT_NAME_FILTERS_COUNT, newFilters.count))];
    [self saveObject:result forKey:kDefaultsLastSelectedNameFilters];
}

+ (NSString *)googlePointsKeyForCity:(HDKCity *)city
{
    NSString *key = kRecentSelectedPoints;
    key = [key stringByAppendingString:city.cityId];
    return key;
}

+ (NSArray *)getRecentFilterPointsForCity:(HDKCity *)city
{
    NSString *key = [self googlePointsKeyForCity:city];
    NSArray *points = [self loadObjectWithKey:key];
    return points;
}

+ (void)addRecentFilterPoint:(HDKLocationPoint *)point forCity:(HDKCity *)city
{
    if ([point isKindOfClass:[HLCityLocationPoint class]]) {
        return;
    }
    NSString *key = [self googlePointsKeyForCity:city];
    NSMutableArray *points = [[self loadObjectWithKey:key] mutableCopy];
    if (points == nil) {
        points = [NSMutableArray new];
    }

    if ([points containsObject:point]) {
        [points removeObject:point];
    }

    [points insertObject:point atIndex:0];
    NSArray *result = [points subarrayWithRange:NSMakeRange(0, MIN(HL_MAX_RECENT_GOOGLE_POINTS, points.count))];
    [self saveObject:result forKey:key];
}

@end
