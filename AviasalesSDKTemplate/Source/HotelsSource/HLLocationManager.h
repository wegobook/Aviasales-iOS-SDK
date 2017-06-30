#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * _Nonnull const kCurrentLocationDestinationKey;
extern NSString * _Nonnull const kForceCurrentLocationToSearchForm;
extern NSString * _Nonnull const kStartCurrentLocationSearch;
extern NSString * _Nonnull const kShowCurrentLocationOnMap;

@interface HLLocationManager : NSObject

+ (HLLocationManager * _Nonnull)sharedManager;
- (CLLocation * _Nullable)location;
- (void)requestUserLocationWithLocationDestination:(NSString * _Nullable)destination;
- (BOOL)locationAuthorizationRequested;
- (void)startUpdatingLocationIfAllowed;
- (void)stopUpdatingLocation;

- (void)hasUserDeniedLocationAccessOnCompletion:(void (^ _Nullable)(BOOL accessDenied))completion;
- (void)hasUserGrantedLocationAccessOnCompletion:(void (^ _Nullable)(BOOL accessGranted))completion;

@end
