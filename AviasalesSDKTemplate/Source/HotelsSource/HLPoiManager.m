#import "HLPoiManager.h"
#import <CoreLocation/CoreLocation.h>
#import <HotellookSDK/HotellookSDK.h>
#import "NSArray+Functional.h"

@implementation HLPoiManager

+ (nullable HDKLocationPoint *)filterPoint:(Filter *)filter variant:(HLResultVariant *)variant
{
    HDKLocationPoint *point = filter.distanceLocationPoint;
    if (![point isKindOfClass:[HLGenericCategoryLocationPoint class]]) {
        return point;
    }
    HLGenericCategoryLocationPoint *castedPoint = (HLGenericCategoryLocationPoint *)point;

    CGFloat distance = CGFLOAT_MAX;
    HDKLocationPoint *nearestPointOfCategory = nil;
    for (HDKLocationPoint *pointOfCategory in variant.hotel.importantPoiArray) {
        if ([pointOfCategory.category isEqualToString:castedPoint.category]) {
            if (pointOfCategory.distanceToHotel < distance) {
                nearestPointOfCategory = pointOfCategory;
                distance = pointOfCategory.distanceToHotel;
            }
        }
    }

    return nearestPointOfCategory;
}

+ (NSArray <HDKLocationPoint *> *)selectHotelDetailsPoints:(HLResultVariant *)variant filter:(nullable Filter *)filter
{
    HDKLocationPoint * filterSelectedPoint = filter.distanceLocationPoint;
    CLLocation *userLocation = [HLLocationManager sharedManager].location;
    HDKCity *currentCity = [HLNearbyCitiesDetector shared].nearbyCities.firstObject;
    HDKSearchLocationPoint *customSearchPoint = variant.searchInfo.locationPoint;

    return [self selectHotelDetailsPoints:variant.hotel filterSelectedPoint:filterSelectedPoint userLocation:userLocation customSearchPoint:customSearchPoint userCurrentCity:currentCity];
}

+ (NSArray <HDKLocationPoint *> *)allPoints:(HDKHotel *)hotel filter:(nullable Filter *)filter
{
    HDKCity *city = hotel.city;
    NSMutableArray <HDKLocationPoint *> *result = [[NSMutableArray alloc] initWithArray:hotel.importantPoiArray];
    result = [[self selectUniquePointFrom:result
                                whitelist:[self categoriesWhitelistForSeasons:city.seasons]
                  allowMultipleEntriesFor:[self mapMultipleEntriesCategoriesForSeasons:city.seasons]] mutableCopy];

    HLCityLocationPoint *centerPoi = [[HLCityLocationPoint alloc] initWithCity:city];
    centerPoi.distanceToHotel = [HLDistanceCalculator getDistanceFromCity:city toHotel:hotel];
    [result addObject:centerPoi];

    HDKLocationPoint *point = filter.distanceLocationPoint;
    if ([self shouldAddPoint:point toMapList:result]) {
        [result addObject:point];
    }

    return result;
}

+ (NSArray <HDKLocationPoint *> *)filterPoints:(nullable NSArray <HDKLocationPoint *> *)points
                                  byCategories:(NSArray <NSString *> *)categories
{
    return [points filter:^BOOL(HDKLocationPoint *point) {
        return [categories containsObject:point.category];
    }];
}

+ (NSArray <HDKLocationPoint *> *)allUniquePointsForCities:(nullable NSArray <HDKCity *> *)cities
{
    NSMutableSet *set = [NSMutableSet new];
    for (HDKCity *city in cities) {
        [set addObjectsFromArray:city.points];
    }
    return [set allObjects];
}

#pragma mark - Private

+ (NSArray <HDKLocationPoint *> *)selectHotelDetailsPoints:(HDKHotel *)hotel
                                       filterSelectedPoint:(HDKLocationPoint *)filterPoint
                                              userLocation:(CLLocation *)userLocation
                                         customSearchPoint:(HDKSearchLocationPoint *)customSearchPoint
                                           userCurrentCity:(HDKCity *)currentCity;
{
    HDKCity *city = hotel.city;
    NSMutableArray <HDKLocationPoint *> *result = [[NSMutableArray alloc] initWithArray:hotel.importantPoiArray];
    result = [[self selectUniquePointFrom:result
                                whitelist:[self categoriesWhitelistForSeasons:city.seasons]
                  allowMultipleEntriesFor:nil] mutableCopy];

    if (city.name) {
        HLCityLocationPoint *centerPoi = [[HLCityLocationPoint alloc] initWithCity:city];
        centerPoi.distanceToHotel = [HLDistanceCalculator getDistanceFromCity:city toHotel:hotel];
        [result addObject:centerPoi];
    }

    BOOL shouldAddCustomSearchPoint = customSearchPoint != nil;
    if ([customSearchPoint isKindOfClass:[HLSearchAirportLocationPoint class]]) {
        HLSearchAirportLocationPoint *airportLocationPoint = (HLSearchAirportLocationPoint *)customSearchPoint;

        shouldAddCustomSearchPoint = [result hl_firstMatch:^BOOL (HDKLocationPoint *locationPoint) {
            return locationPoint.category == HDKLocationPointCategory.kAirport && [locationPoint.pointId isEqualToString:airportLocationPoint.airport.airportId];
        }] != nil;
    }

    if (shouldAddCustomSearchPoint) {
        HDKLocationPoint *customPoint = [[HDKLocationPoint alloc] initWithName:NSLS(@"HL_LOC_SEARCH_POINT_TEXT") location:customSearchPoint.location];
        customPoint.distanceToHotel = [HLDistanceCalculator getDistanceFromLocationPoint:customPoint toHotel:hotel];
        [result addObject:customPoint];
    }

    if ([self shouldAddPoint:filterPoint toDetailsList:result]) {
        filterPoint.distanceToHotel = [HLDistanceCalculator getDistanceFromLocationPoint:filterPoint toHotel:hotel];
        [result addObject:filterPoint];
    }

    return [self sortedPointsByDistance:result];
}

+ (NSSet *)categoriesWhitelistForSeasons:(NSArray <HDKSeason *> *)seasons
{
    NSMutableSet *result = [NSMutableSet setWithObjects:HDKLocationPointCategory.kMetroStation, @"stadium", HDKLocationPointCategory.kTrainStation, HDKLocationPointCategory.kAirport, HDKLocationPointCategory.kUserLocation, HDKLocationPointCategory.kCityCenter, nil];
    if ([self seasons:seasons haveCategory:HDKLocationPointCategory.kBeach]) {
        [result addObject:HDKLocationPointCategory.kBeach];
    }
    if ([self seasons:seasons haveCategory:HDKSeason.kSkiSeasonCategory]) {
        [result addObject:HDKLocationPointCategory.kSkilift];
    }
    return result;
}

+ (NSSet *)mapMultipleEntriesCategoriesForSeasons:(NSArray <HDKSeason *> *)seasons
{
    NSMutableSet *result = [NSMutableSet setWithObjects:HDKLocationPointCategory.kAirport, HDKLocationPointCategory.kTrainStation, nil];
    if ([self seasons:seasons haveCategory:HDKLocationPointCategory.kBeach]) {
        [result addObject:HDKLocationPointCategory.kBeach];
    }
    if ([self seasons:seasons haveCategory:HDKSeason.kSkiSeasonCategory]) {
        [result addObject:HDKLocationPointCategory.kSkilift];
    }
    return result;
}

+ (NSArray <HDKLocationPoint *> *)selectUniquePointFrom:(NSArray <HDKLocationPoint *> *)sourceArray
                                              whitelist:(NSSet *)whitelistSet
                                allowMultipleEntriesFor:(NSSet *)multipleEntriesSet
{
    NSArray *sortedArray = [self sortedPointsByDistance:sourceArray];

    NSMutableArray *result = [NSMutableArray new];
    NSMutableSet *takenCategories = [NSMutableSet new];
    for (HDKLocationPoint *point in sortedArray) {
        NSString *category = point.category;
        if (!category || [multipleEntriesSet containsObject:category]) {
            [result addObject:point];
        } else {
            if (![takenCategories containsObject:category] && [whitelistSet containsObject:category]) {
                [takenCategories addObject:category];
                [result addObject:point];
            }
        }
    }

    return result;
}

+ (NSArray *)sortedPointsByDistance:(NSArray <HDKLocationPoint *> *)points
{
    return [points sortedArrayUsingComparator:^NSComparisonResult(HDKLocationPoint *point1, HDKLocationPoint *point2) {
        return (point1.distanceToHotel < point2.distanceToHotel) ? NSOrderedAscending : NSOrderedDescending;
    }];
}

+ (BOOL)shouldAddPoint:(nullable HDKLocationPoint *)point toMapList:(NSArray <HDKLocationPoint *> *)list
{
    return (point &&
            ![point isKindOfClass:[HLGenericCategoryLocationPoint class]] &&
            ![list containsObject:point]);
}

+ (BOOL)shouldAddPoint:(HDKLocationPoint *)point toDetailsList:(NSArray <HDKLocationPoint *> *)list
{
    return (point &&
            ![point isKindOfClass:[HLGenericCategoryLocationPoint class]] &&
            ![self list:list containsPointWithNameEqualTo:point]);
}

+ (BOOL)list:(NSArray <HDKLocationPoint *> *)list containsPointWithNameEqualTo:(HDKLocationPoint *)point
{
    for (HDKLocationPoint *p in list) {
        if ([p.name isEqualToString:point.name]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Point selection screen
+ (NSArray <HDKLocationPoint *> *)pointsFrom:(NSArray <HDKLocationPoint *> *)points
                              pointsCategory:(NSString *)pointsCategory
                              seasonCategory:(NSString *)seasonCategory
                                     seasons:(nullable NSArray <HDKSeason *> *)seasons
{
    if ([self seasons:seasons haveCategory:seasonCategory]) {
        return [self filterPoints:points byCategories:@[pointsCategory]];
    }

    return @[];
}

+ (BOOL)seasons:(NSArray <HDKSeason *> *)seasons haveCategory:(NSString *)category
{
    for (HDKSeason *season in seasons) {
        if ([season.category isEqualToString:category]) {
            return YES;
        }
    }
    return NO;
}

@end
