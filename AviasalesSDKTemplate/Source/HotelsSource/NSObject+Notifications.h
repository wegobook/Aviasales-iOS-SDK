#import <Foundation/Foundation.h>

@protocol HLNearbyCitiesDetectionDelegate <NSObject>

@optional

- (void)nearbyCitiesDetectionStarted:(NSNotification *)notification;
- (void)nearbyCitiesDetected:(NSNotification *)notification;
- (void)nearbyCitiesDetectionFailed:(NSNotification *)notification;
- (void)nearbyCitiesDetectionCancelled:(NSNotification *)notification;
- (void)locationServicesAccessFailed:(NSNotification *)notification;
- (void)locationDetectionFailed:(NSNotification *)notification;

@end

@protocol HLSearchInfoChangeDelegate <NSObject>

@optional

- (void)searchInfoChangedNotification:(NSNotification *)notification;

@end

@protocol HLLocationManagerDelegate <NSObject>

@optional

- (void)locationUpdatedNotification:(NSNotification *)notification;
- (void)locationUpdateFailedNotification:(NSNotification *)notification;
- (void)locationServicesAccessFailedNotification:(NSNotification *)notification;

@end

@protocol HLCityInfoLoadingProtocol <NSObject>

@optional

- (void)cityInfoDidLoad:(NSNotification *)notification;
- (void)cityInfoLoadingFailed:(NSNotification *)notification;
- (void)cityInfoLoadingCancelled:(NSNotification *)notification;

@end

@interface NSObject (RegisterForNotifications)
- (void)registerForSearchInfoChangesNotifications;
- (void)registerForCurrentCityNotifications;
- (void)registerForLocationManagerNotifications;
- (void)registerCityInfoLoadingNotifications;
- (void)unregisterLocationNotifications;
- (void)unregisterNotificationResponse;
@end
