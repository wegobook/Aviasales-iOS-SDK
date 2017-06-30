#import "HLMapRegionCalculator.h"
#import <HotellookSDK/HotellookSDK.h>

@implementation HLMapRegionCalculator

+ (MKCoordinateRegion)regionContainingLocations:(NSArray <CLLocation *> *)locations spanCoeff:(CGFloat)spanCoeff
{
    return [self regionContainingLocations:locations spanHorizontal:spanCoeff spanVertical:spanCoeff];
}

+ (MKCoordinateRegion)regionContainingLocations:(NSArray <CLLocation *> *)locations
                                 spanHorizontal:(CGFloat)spanHorizontal
                                 spanVertical:(CGFloat)spanVertical
{
    double minLat = DBL_MAX;
    double maxLat = -DBL_MAX;
    double minLon = DBL_MAX;
    double maxLon = -DBL_MAX;

    for (CLLocation *loc in locations) {
        float lat = loc.coordinate.latitude;
        float lon = loc.coordinate.longitude;
        minLat = MIN(minLat, lat);
        maxLat = MAX(maxLat, lat);
        minLon = MIN(minLon, lon);
        maxLon = MAX(maxLon, lon);
    }
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake((maxLat + minLat)/2.0, (maxLon + minLon)/2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat) * spanHorizontal, (maxLon - minLon) * spanVertical);

    return MKCoordinateRegionMake(coord, span);
}

+ (BOOL)coordinateRegion:(MKCoordinateRegion)region containsCoordinate:(CLLocationCoordinate2D)coordinate
{
    return coordinate.latitude > region.center.latitude - (region.span.latitudeDelta / 2.0) &&
        coordinate.latitude < region.center.latitude + (region.span.latitudeDelta / 2.0) &&
        coordinate.longitude > region.center.longitude - (region.span.longitudeDelta / 2.0) &&
        coordinate.longitude < region.center.longitude + (region.span.longitudeDelta / 2.0);
}

+ (BOOL)isHotelCoordinateValid:(HDKHotel *)hotel
{
    if ([hotel isKindOfClass:[HDKHotel class]] == NO) {
        return NO;
    }

    return (fabs(hotel.latitude) > 0.00001 || fabs(hotel.longitude) > 0.00001)
    && fabs(hotel.latitude) < 90.0
    && fabs(hotel.longitude) < 180.0;
}


@end
