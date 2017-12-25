#import "HLLocationManager.h"
#import "HLNearbyCitiesDetector.h"
#import "HLAlertsFabric.h"
//#import "HLDevSettingsVC.h"

NSString * const kCurrentLocationDestinationKey = @"currentLocationDestination";
NSString * const kForceCurrentLocationToSearchForm = @"kForceCurrentLocationToSearchForm";
NSString * const kStartCurrentLocationSearch = @"startCurrentCitySearch";
NSString * const kShowCurrentLocationOnMap = @"showCurrentLocationOnMap";
CLLocationDistance const kLocationManagerDistanceFilter = 10.0f;

static NSString * kAuthorizationStatusKey = @"authorizationStatus";

@interface HLLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@interface HLDebugLocationManager : HLLocationManager

@end

@implementation HLLocationManager

static HLLocationManager *sharedManager;

+ (HLLocationManager *)sharedManager
{
	if (!sharedManager) {
		static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[HLLocationManager alloc] init];
        });
	}
	
    return sharedManager;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.locationManager = [CLLocationManager new];
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		self.locationManager.distanceFilter = kLocationManagerDistanceFilter;
		self.locationManager.delegate = self;
	}
	
    return self;
}

- (void)startUpdatingLocationIfAllowed
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    if (currentStatus == kCLAuthorizationStatusAuthorizedAlways || currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startUpdatingLocation];
    }
}

- (CLLocation *)location
{
    return self.locationManager.location;
}

- (void)getAuthorizationStatusOnCompletion:(void (^)(CLAuthorizationStatus status))completion
{
    __block void (^localCompletion)(CLAuthorizationStatus status) = [completion copy];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (localCompletion) {
                localCompletion(status);
                localCompletion = nil;
            }
        });
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (localCompletion) {
            localCompletion(kCLAuthorizationStatusNotDetermined);
            localCompletion = nil;
        }
    });
}

- (void)hasUserGrantedLocationAccessOnCompletion:(void (^)(BOOL accessGranted))completion
{
    [self getAuthorizationStatusOnCompletion:^(CLAuthorizationStatus status) {
        completion(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse);
    }];
}

- (void)hasUserDeniedLocationAccessOnCompletion:(void (^)(BOOL accessDenied))completion
{
    [self getAuthorizationStatusOnCompletion:^(CLAuthorizationStatus status) {
        completion(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted);
    }];
}

- (BOOL)locationAuthorizationRequested
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    return (currentStatus != kCLAuthorizationStatusNotDetermined);
}

- (void)requestUserLocationWithLocationDestination:(nullable NSString *)destination
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    switch (currentStatus) {
        case kCLAuthorizationStatusNotDetermined:
        {
            [self.locationManager requestWhenInUseAuthorization];
            HLNearbyCitiesDetector *cityDetector = [HLNearbyCitiesDetector shared];
            if (!cityDetector.currentLocationDestination) {
                cityDetector.currentLocationDestination = destination;
            }
        }
            break;
            
        case kCLAuthorizationStatusDenied:
            [HLAlertsFabric showLocationAlert];
            break;
            
        default:
            [self startUpdatingLocation];
            break;
    }
}

#pragma mark - Private

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
    
    if (![HLNearbyCitiesDetector shared].nearbyCities) {
        HLSearchInfo *searchInfo = [HLSearchInfo defaultSearchInfo];
        [[HLNearbyCitiesDetector shared] detectCurrentCityWithSearchInfo:searchInfo];
    }
}

- (void)stopUpdatingLocation
{
   [self.locationManager stopUpdatingLocation];
}

- (BOOL)accessGrantedWithStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation HLLocationManager (CLLocationManagerDelegate)

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSNotification * notification = [NSNotification notificationWithName:HL_LOCATION_UPDATED_NOTIFICATION object:location];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code != kCLErrorLocationUnknown) {
        [self sendMainThreadNotificationWithName:HL_LOCATION_DETECTION_FAILED_NOTIFICATION];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusDenied:
            [self sendMainThreadNotificationWithName:HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION];
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (void)sendMainThreadNotificationWithName:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:nil
                                                          userInfo:nil];
    });
}

@end

@implementation HLDebugLocationManager

#pragma mark - Override methods

- (CLLocation *)location
{
    return [super location];
}

- (void)getAuthorizationStatusOnCompletion:(void (^)(CLAuthorizationStatus status))completion
{
    [super getAuthorizationStatusOnCompletion:completion];
}

- (BOOL)locationAuthorizationRequested
{
    return [super locationAuthorizationRequested];
}

- (void)requestUserLocation
{
    [super requestUserLocationWithLocationDestination:nil];
}

- (void)startUpdatingLocation
{
    [super startUpdatingLocation];
}


@end
