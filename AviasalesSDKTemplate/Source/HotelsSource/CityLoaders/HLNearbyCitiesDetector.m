#import <HotellookSDK/HotellookSDK.h>

#import "HLNearbyCitiesDetector.h"

#import "NSObject+Notifications.h"
#import "HLLocationManager.h"
#import "HLUrlUtils.h"

@interface HLNearbyCitiesDetector() <HLLocationManagerDelegate>

@property (nonatomic, copy) HLSearchInfo *searchInfo;
@property (nonatomic, strong) HLCitiesByPointDetector *citiesDetector;

@end

@implementation HLNearbyCitiesDetector

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static HLNearbyCitiesDetector *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HLNearbyCitiesDetector alloc] init];
    });
	
    return sharedInstance;
}

#pragma mark - Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        _busy = NO;
        _currentLocationDestination = nil;
        _citiesDetector = [HLCitiesByPointDetector new];
    }
    return self;
}

- (void)detectCurrentCityWithSearchInfo:(HLSearchInfo *)searchInfo
{
    if (self.busy) {
        return;
    }
    
    _busy = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:HL_NEARBY_CITIES_DETECTION_STARTED_NOTIFICATION object:nil userInfo:nil];
    [[HLLocationManager sharedManager] hasUserDeniedLocationAccessOnCompletion:^(BOOL accessDenied) {
        if (!accessDenied) {
            self.searchInfo = searchInfo;
            if ([HLLocationManager sharedManager].location) {
                [self detectCurrentCity];
            } else {
                [self registerForLocationManagerNotifications];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION
                                                                object:nil
                                                              userInfo:nil];
            self->_busy = NO;
        }
    }];
}

- (void)dropCurrentLocationSearchDestination
{
    if (self.currentLocationDestination == kStartCurrentLocationSearch) {
        self.currentLocationDestination = nil;
    }
}

#pragma mark - Private

- (void)detectCurrentCity
{
    self.searchInfo.locationPoint = [HLSearchUserLocationPoint forCurrentLocation];
    @weakify(self)
    [self.citiesDetector detectNearbyCitiesForSearchInfo:self.searchInfo onCompletion:^(NSArray<HDKCity *> *cities){
        @strongify(self)
        [self citiesDetected:cities];
    } onError:^(NSError *error){
        @strongify(self)
        [self citiesDetectionFailed:error];
    }];
}

- (void)citiesDetected:(NSArray<HDKCity *> *)cities
{
    _nearbyCities = cities;

    dispatch_async(dispatch_get_main_queue(), ^{

        NSDictionary *userInfo = nil;
        if (self.currentLocationDestination) {
            userInfo = @{kCurrentLocationDestinationKey : self.currentLocationDestination};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HL_NEARBY_CITIES_DETECTED_NOTIFICATION
                                                            object:self.nearbyCities
                                                          userInfo:userInfo];
    });

    _busy = NO;
}

- (void)citiesDetectionFailed:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.code == NSURLErrorCancelled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HL_NEARBY_CITIES_DETECTION_CANCELLED_NOTIFICATION
                                                                object:nil
                                                              userInfo:nil];
        } else {
            NSError *error = [NSError errorWithCode:HLManagedCityDetectionFailed];
            [[NSNotificationCenter defaultCenter] postNotificationName:HL_NEARBY_CITIES_DETECTION_FAILED_NOTIFICATION
                                                                object:error
                                                              userInfo:nil];
        }
    });
    _busy = NO;
}

#pragma mark - HLLocationManager Notifications Response Methods

- (void)locationUpdatedNotification:(NSNotification *)notification
{
    if (self.nearbyCities.firstObject == nil) {
		[self unregisterLocationNotifications];
        [self detectCurrentCity];
	}
}

- (void)locationUpdateFailedNotification:(NSNotification *)notification
{
	[self unregisterLocationNotifications];
    
    _busy = NO;
}

- (void)locationServicesAccessFailedNotification:(NSNotification *)notification;
{
	[self unregisterLocationNotifications];
    
    _busy = NO;
}

- (void)dropCurrentLocation
{
    _nearbyCities = nil;
}

@end
