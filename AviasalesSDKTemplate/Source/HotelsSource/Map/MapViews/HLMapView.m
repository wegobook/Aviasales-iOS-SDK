#import "HLMapView.h"
#import <HotellookSDK/HotellookSDK.h>
#import "HLResultVariant.h"
#import "HLMapRegionCalculator.h"
#import "HLDistanceCalculator.h"

#define HL_CITY_REGION_SPAN 0.075f
#define HL_VARIANTS_SPAN_COEFF_H 1.2f
#define HL_VARIANTS_SPAN_COEFF_V 1.2f

static CGFloat kMapSpanCoeff = 1.2f;

@interface HLMapView() <UIGestureRecognizerDelegate>
@end

@implementation HLMapView

- (id)init
{
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    [self initialize];
}

- (void)initialize
{
    self.showsUserLocation = false;
	self.rotateEnabled = NO;
    
    NSArray *gestureRec = self.gestureRecognizers;
    for (UIGestureRecognizer *rec in gestureRec) {
        rec.delegate = self;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *resultView = [super hitTest:point withEvent:event];
    if (self.gestureRecognizerDelegate && [self.gestureRecognizerDelegate mapShouldReactOnTouchAtPoint:point] == NO) {
        self.scrollEnabled = NO;
        [self lockAllGestureRecognizers:YES];
    } else {
        self.scrollEnabled = YES;
        [self lockAllGestureRecognizers:NO];
    }
    
    return resultView;
}

#pragma mark - Public

+ (UIEdgeInsets)defaultInsets
{
    return UIEdgeInsetsMake(30.0, 30.0, 50.0, 30.0);
}

- (void)setRegion:(MKCoordinateRegion)region insets:(UIEdgeInsets)insets animated:(BOOL)animated
{
    MKMapRect rect = [self mapRectForRegion:region];
    [self setVisibleMapRect:rect edgePadding:insets animated:animated];
}

- (void) centerOnVariant:(HLResultVariant *)variant
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(variant.hotel.latitude, variant.hotel.longitude);
    CGPoint pinPosition = [self convertCoordinate:coord toPointToView:self];
    pinPosition.y -= ceil([HLSingleAnnotationView calloutHeight] / 2.0);
    CLLocationCoordinate2D newCenterCoord = [self convertPoint:pinPosition toCoordinateFromView:self];

    [self setCenterCoordinate:newCenterCoord animated:YES];
}

- (void)showCity:(HDKCity *)city
{
    MKCoordinateRegion region = [self regionForCity:city];
    [self setRegion:region animated:YES];
}

- (void)setRegionForVariants:(NSArray *)variantsArray insets:(UIEdgeInsets)insets animated:(BOOL)animated
{
    MKCoordinateRegion region = [self regionForVariants:variantsArray];
    [self setRegion:region insets:insets animated:animated];
}

- (MKMapRect)mapRectForRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

- (void)setRegionForUserLocation
{
    MKCoordinateRegion region = [self regionForUserLocation];
    [self setRegion:region animated:YES];
}

- (void)setRegionForUserAndTheCity:(HDKCity *)city
{
    MKCoordinateRegion region = [self regionForUserAndCity:city];
    [self setRegion:region animated:YES];
}

- (BOOL)canUngroupVariants:(NSArray *)variants
{
    double limitValue = 0.0015;

    double minLat = DBL_MAX;
    double maxLat = -DBL_MAX;
    double minLon = DBL_MAX;
    double maxLon = -DBL_MAX;

    for (HLResultVariant * variant in variants) {
        HDKHotel * hotel = variant.hotel;
        if ([HLMapRegionCalculator isHotelCoordinateValid:hotel]) {
            float lat = hotel.latitude;
            float lon = hotel.longitude;

            minLat = MIN(minLat, lat);
            maxLat = MAX(maxLat, lat);
            minLon = MIN(minLon, lon);
            maxLon = MAX(maxLon, lon);
        }
        if ((maxLat - minLat > limitValue) || (maxLon - minLon) > limitValue) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Region calculations

- (MKCoordinateRegion)regionForCity:(HDKCity *)city
{
	CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(city.latitude, city.longitude);
	MKCoordinateSpan span = MKCoordinateSpanMake(HL_CITY_REGION_SPAN, HL_CITY_REGION_SPAN);
	MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
	return region;
}

- (MKCoordinateRegion)regionForVariants:(NSArray <HLResultVariant *> *)variantsArray
{
    NSMutableArray *locations = [NSMutableArray new];
    for (HLResultVariant *variant in variantsArray) {
        if ([HLMapRegionCalculator isHotelCoordinateValid:variant.hotel]) {
            [locations addObject:[[CLLocation alloc] initWithLatitude:variant.hotel.latitude longitude:variant.hotel.longitude]];
        }
    }

    return [HLMapRegionCalculator regionContainingLocations:locations spanHorizontal:HL_VARIANTS_SPAN_COEFF_H spanVertical:HL_VARIANTS_SPAN_COEFF_V];
}

- (MKCoordinateRegion) regionForUserLocation
{
	CLLocationCoordinate2D coord = [HLLocationManager sharedManager].location.coordinate;
	MKCoordinateSpan span = MKCoordinateSpanMake(HL_CITY_REGION_SPAN, HL_CITY_REGION_SPAN);
	MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
	return region;
}

- (MKCoordinateRegion)regionForUserAndCity:(HDKCity *)city
{
    CLLocation *userLoc = [HLLocationManager sharedManager].location;
    if (userLoc != nil) {
        CLLocation *cityLoc = [[CLLocation alloc] initWithLatitude:city.latitude longitude:city.longitude];
        MKCoordinateRegion result = [HLMapRegionCalculator regionContainingLocations:@[userLoc, cityLoc] spanCoeff:kMapSpanCoeff];
        result = [self regionThatFits:result];
        if (![HLMapRegionCalculator coordinateRegion:result containsCoordinate:cityLoc.coordinate]) {
            result = [self regionForUserLocation];
        }

        return result;
    }

    return [self regionForCity:city];
}

#pragma mark - Private methods

- (void)lockAllGestureRecognizers:(BOOL)lock
{
    for (UIGestureRecognizer *rec in self.gestureRecognizers) {
        rec.enabled = !lock;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }

    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[MKAnnotationView class]]) {
        [_gestureRecognizerDelegate mapWillReceiveTouchOnAnnotationView:(MKAnnotationView *)touch.view];
    }
    return YES;
}

@end
