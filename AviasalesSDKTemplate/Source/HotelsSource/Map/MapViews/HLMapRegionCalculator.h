#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class HDKHotel;

@interface HLMapRegionCalculator : NSObject

+ (MKCoordinateRegion)regionContainingLocations:(NSArray <CLLocation *> *)locations spanCoeff:(CGFloat)spanCoeff;
+ (MKCoordinateRegion)regionContainingLocations:(NSArray <CLLocation *> *)locations
                                 spanHorizontal:(CGFloat)spanHorizontal
                                   spanVertical:(CGFloat)spanVertical;
+ (BOOL)coordinateRegion:(MKCoordinateRegion)region containsCoordinate:(CLLocationCoordinate2D)coordinate;
+ (BOOL)isHotelCoordinateValid:(HDKHotel *)hotel;

@end
