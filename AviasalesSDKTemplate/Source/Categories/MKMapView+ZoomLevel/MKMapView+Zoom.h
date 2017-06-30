#import <MapKit/MapKit.h>

@interface MKMapView (Zoom)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                       zoom:(double)zoom
                   animated:(BOOL)animated;
- (double)zoom;

@end
