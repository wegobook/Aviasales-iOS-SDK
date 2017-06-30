//
//  JRAppDelegate.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAppDelegate.h"
#import "JRAppLauncher.h"
#import "JRColorScheme.h"

@implementation JRAppDelegate

+ (void)openSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [JRAppLauncher startServicesWithAPIToken:kJRAPIToken
                               partnerMarker:kJRPartnerMarker
                              appodealAPIKey:kAppodealApiKey];

    // Screen initializing
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    TabMenuVC *menuVC = [[TabMenuVC alloc] init];
    
    self.window.tintColor = [JRColorScheme tintColor];
    
    [self.window setRootViewController:menuVC];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
