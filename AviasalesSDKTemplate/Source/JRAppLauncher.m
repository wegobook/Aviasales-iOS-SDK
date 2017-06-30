//
//  JRAppLauncher.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAppLauncher.h"
#import "JRAdvertisementManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation JRAppLauncher

+ (void)startServicesWithAPIToken:(NSString *)APIToken
                    partnerMarker:(NSString *)partnerMarker
                   appodealAPIKey:(NSString *)appodealAPIKey {
#ifndef DEBUG
    [Fabric with:@[[Crashlytics class]]];
#endif
    
    // Aviasale SDK
    [AviasalesSDK setupWithConfiguration:[AviasalesSDKInitialConfiguration configurationWithAPIToken:APIToken APILocale:[NSLocale currentLocale].localeIdentifier partnerMarker:partnerMarker]];

    if (appodealAPIKey) {
        // Advertisement initializing
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            JRAdvertisementManager *const adManager = [JRAdvertisementManager sharedInstance];
            [adManager initializeAppodealWithAPIKey:appodealAPIKey testingEnabled:kAppodealTestingMode];
        });
    }
}

@end
