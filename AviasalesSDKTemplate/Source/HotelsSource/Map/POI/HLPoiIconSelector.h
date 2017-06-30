#import <Foundation/Foundation.h>

@class HDKCity;
@class PoiAnnotation;
@class MKAnnotationView;
@class MKMapView;
@class HDKLocationPoint;

@interface HLPoiIconSelector : NSObject

+ (UIImage *)listPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city;
+ (UIImage *)mapPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city;
+ (MKAnnotationView *)annotationView:(PoiAnnotation *)annotation mapView:(MKMapView *)mapView city:(HDKCity *)city;

@end
