#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKMapView (Refresh)
- (void)hl_refreshAnnotationsAnimated:(BOOL)animated;
@end