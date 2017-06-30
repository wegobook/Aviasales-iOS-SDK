#import <HotellookSDK/HotellookSDK.h>

#import "HLDistanceCalculator.h"
#import <MapKit/MapKit.h>
#import "HLApiCoordinate.h"
#import "HLResultVariant.h"
#import "HLPoiManager.h"

@implementation HLDistanceCalculator

+ (HLDistanceCalculator *) sharedCalculator
{
	static HLDistanceCalculator *calculator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calculator = [[HLDistanceCalculator alloc] init];
    });
    
	return calculator;
}

- (double)getDistanceFromUserToLocation:(CLLocation *)location
{
//	HLLocationManager * manager = [HLLocationManager sharedManager];
//	CLLocation * currentLocation = [manager location];
//	if(currentLocation){
//		return [location distanceFromLocation:currentLocation];
//	}
//	else{
		return -1;
//	}
}

+ (double)getDistanceFromHotel:(HDKHotel *)hotel toLocation:(CLLocation *)location
{
	CLLocation *hotelLocation = [[CLLocation alloc] initWithLatitude:hotel.latitude longitude:hotel.longitude];
    return [hotelLocation distanceFromLocation:location];
}

+ (double)getDistanceFromUserToHotel:(HDKHotel *)hotel
{
	CLLocation * location = [[CLLocation alloc] initWithLatitude:hotel.latitude longitude:hotel.longitude];
	return [[HLDistanceCalculator sharedCalculator] getDistanceFromUserToLocation:location];
}

+ (double)getDistanceFromLocationPoint:(HDKLocationPoint *)point toHotel:(HDKHotel *)hotel
{
    CLLocation * loc1 = [[CLLocation alloc] initWithLatitude:hotel.latitude longitude:hotel.longitude];
    return [loc1 distanceFromLocation:point.location];
}

+ (double) getDistanceFromCity:(HDKCity *)city toHotel:(HDKHotel *)hotel
{
	CLLocation * loc1 = [[CLLocation alloc] initWithLatitude:hotel.latitude longitude:hotel.longitude];
	CLLocation * loc2 = [[CLLocation alloc] initWithLatitude:city.latitude longitude:city.longitude];
	
    return [loc1 distanceFromLocation:loc2];
}

+ (CGFloat)getDistanceFromHotel:(HDKHotel *)hotel toPointsOfCategory:(NSString *)category undefinedDistance:(CGFloat)undefinedDistance
{
    CGFloat distance = undefinedDistance;
    NSArray *filteredPoints = [HLPoiManager filterPoints:hotel.importantPoiArray byCategories:@[category]];
    for (HDKLocationPoint *point in filteredPoints) {
        distance = MIN(distance, [self getDistanceFromLocationPoint:point toHotel:hotel]);
    }
    return distance;
}

+ (double)convertKilometersToMiles:(double)kilometers
{
    return kilometers;
//	return kilometers/HL_MILE_LENGTH;
}

+ (double)convertMetersToKilometers:(double)meters
{
    return meters / 1000.0;
}

+ (void)calculateDistancesFromVariants:(NSArray *)variants toLocationPoint:(HDKLocationPoint *)point
{
    for (HLResultVariant * variant in variants) {
        CGFloat distance = [HLDistanceCalculator getDistanceFromLocationPoint:point toHotel:variant.hotel];
        variant.distanceToCurrentLocationPoint = distance;
    }
}

@end
