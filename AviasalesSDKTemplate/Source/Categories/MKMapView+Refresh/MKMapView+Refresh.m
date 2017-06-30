#import "MKMapView+Refresh.h"


@implementation MKMapView (Refresh)

- (void)hl_refreshAnnotationsAnimated:(BOOL)animated
{
    if (animated) {
        NSArray <id <MKAnnotation>> *annotations = self.annotations;
        [self removeAnnotations:annotations];
        [self addAnnotations:annotations];
    } else {
        // http://stackoverflow.com/a/1205230
        [self setCenterCoordinate:self.region.center animated:NO];
    }
}

@end