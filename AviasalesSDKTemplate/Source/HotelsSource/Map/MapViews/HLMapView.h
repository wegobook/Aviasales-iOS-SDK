#import <MapKit/MapKit.h>
#import "HLResultVariant.h"

@protocol HLMapViewDelegate <NSObject>
- (BOOL)mapShouldReactOnTouchAtPoint:(CGPoint)point;
- (void)mapWillReceiveTouchOnAnnotationView:(MKAnnotationView *)view;
@end

@interface HLMapView : MKMapView

@property (nonatomic, weak) id <HLMapViewDelegate> gestureRecognizerDelegate;

- (void)centerOnVariant:(HLResultVariant *)variant;
- (void)showCity:(HDKCity *)city;
- (void)setRegionForVariants:(NSArray <HLResultVariant *> *)variantsArray insets:(UIEdgeInsets)insets animated:(BOOL)animated;
- (void)setRegionForUserLocation;
- (void)setRegionForUserAndTheCity:(HDKCity *)city;
- (BOOL)canUngroupVariants:(NSArray *)variants;

+ (UIEdgeInsets)defaultInsets;
- (void)setRegion:(MKCoordinateRegion)region insets:(UIEdgeInsets)insets animated:(BOOL)animated;

@end
