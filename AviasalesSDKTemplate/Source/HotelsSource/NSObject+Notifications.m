#import "NSObject+Notifications.h"

@implementation NSObject (RegisterForNotifications)

- (void)registerForSearchInfoChangesNotifications
{
    NSAssert([self conformsToProtocol:@protocol(HLSearchInfoChangeDelegate)], @"Cannot register for notifications. Doesn't conform HLSearchInfoChangeDelegate protocol");

    [self subscribeToNotification:HL_SEARCHINFO_CHANGED withSelector:@selector(searchInfoChangedNotification:)];
}

- (void)registerForCurrentCityNotifications
{
	NSAssert([self conformsToProtocol:@protocol(HLNearbyCitiesDetectionDelegate)], @"Cannot register for notifications. Doesn't conform HLNearbyCitiesDetectionDelegate protocol");

    [self subscribeToNotification:HL_NEARBY_CITIES_DETECTION_STARTED_NOTIFICATION withSelector:@selector(nearbyCitiesDetectionStarted:)];
    [self subscribeToNotification:HL_NEARBY_CITIES_DETECTED_NOTIFICATION withSelector:@selector(nearbyCitiesDetected:)];
    [self subscribeToNotification:HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION withSelector:@selector(nearbyCitiesDetectionFailed:)];
    [self subscribeToNotification:HL_NEARBY_CITIES_DETECTION_CANCELLED_NOTIFICATION withSelector:@selector(nearbyCitiesDetectionCancelled:)];
    [self subscribeToNotification:HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION withSelector:@selector(locationServicesAccessFailed:)];
    [self subscribeToNotification:HL_LOCATION_DETECTION_FAILED_NOTIFICATION withSelector:@selector(locationDetectionFailed:)];
}

- (void)registerForLocationManagerNotifications
{
    NSAssert([self conformsToProtocol:@protocol(HLLocationManagerDelegate)], @"Cannot register for notifications. Doesn't conform HLLocationManagerDelegate protocol");

    [self subscribeToNotification:HL_LOCATION_UPDATED_NOTIFICATION withSelector:@selector(locationUpdatedNotification:)];
    [self subscribeToNotification:HL_LOCATION_DETECTION_FAILED_NOTIFICATION withSelector:@selector(locationUpdateFailedNotification:)];
    [self subscribeToNotification:HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION withSelector:@selector(locationServicesAccessFailedNotification:)];
}

- (void)registerCityInfoLoadingNotifications
{
    NSString *message = [NSString stringWithFormat:@"Cannot register %@ for notifications. Doesn't conform HLCityInfoLoadingDelegate protocol", [self description]];
    NSAssert([self conformsToProtocol:@protocol(HLCityInfoLoadingProtocol)], message);

    [self subscribeToNotification:HL_CITY_INFO_LOADING_FINISHED_NOTIFICATION withSelector:@selector(cityInfoDidLoad:)];
    [self subscribeToNotification:HL_CITY_INFO_LOADING_FAILED_NOTIFICATION withSelector:@selector(cityInfoLoadingFailed:)];
    [self subscribeToNotification:HL_CITY_INFO_LOADING_CANCELLED_NOTIFICATION withSelector:@selector(cityInfoLoadingCancelled:)];
}

- (void)unregisterLocationNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HL_LOCATION_UPDATED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HL_LOCATION_DETECTION_FAILED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HL_LOCATION_SERVICES_ACCESS_FAILED_NOTIFICATION object:nil];
}

- (void)unregisterNotificationResponse
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscribeToNotification:(NSString *)notification withSelector:(SEL)selector
{
    if ([self respondsToSelector:selector]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notification object:nil];
    }
}

@end
