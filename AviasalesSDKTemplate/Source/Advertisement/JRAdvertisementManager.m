//
//  JRAdvertisementManager.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Appodeal/Appodeal.h>

#import "JRAdvertisementManager.h"
#import "JRVideoAdLoader.h"
#import "JRNewsFeedAdLoader.h"
#import "JRAviasalesAdLoader.h"

@interface JRAdvertisementManager()

@property (nonatomic, strong, readwrite) UIView *cachedAviasalesAdView;

@end

@implementation JRAdvertisementManager {
    NSMutableSet *_adLoaders;
}

+ (instancetype)sharedInstance {
    static JRAdvertisementManager *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[JRAdvertisementManager alloc] init];
    });
    return result;
}

- (instancetype)init {
    if (self = [super init]) {
        _showsAdDuringSearch = YES;
        _showsAdOnSearchResults = NO;
        _adLoaders = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)initializeAppodealWithAPIKey:(NSString *)appodealAPIKey testingEnabled:(BOOL)testingEnabled {
#ifdef DEBUG
    [Appodeal setTestingEnabled:testingEnabled];
#endif
    [Appodeal initializeWithApiKey:appodealAPIKey
                             types:AppodealAdTypeInterstitial | AppodealAdTypeNativeAd];
}

- (void)presentVideoAdInViewIfNeeded:(UIView *)view
                  rootViewController:(UIViewController *)viewController{
    if (!self.showsAdDuringSearch) {
        return;
    }

    JRVideoAdLoader *const videoLoader = [[JRVideoAdLoader alloc] init];
    videoLoader.rootViewController = viewController;

    NSMutableSet *const loaders = _adLoaders;
    [loaders addObject:videoLoader];

    __weak UIViewController *weakViewController = viewController;
    [videoLoader loadVideoAd:^(APDMediaView *adView, APDNativeAd *ad) {
        [loaders removeObject:videoLoader];

        if (adView != nil) {
            [view addSubview:adView];
            adView.translatesAutoresizingMaskIntoConstraints = NO;
            [view addConstraints:JRConstraintsMakeScaleToFill(adView, view)];
            [ad attachToView:view viewController:viewController];
        } else {
            UIViewController *const viewController = weakViewController;
            if (viewController && [Appodeal isReadyForShowWithStyle:AppodealShowStyleInterstitial]) {
                [Appodeal showAd:AppodealShowStyleInterstitial rootViewController:viewController];
            }
        }
    }];
}

- (void)loadAndCacheAviasalesAdViewWithSearchInfo:(JRSDKSearchInfo *)searchInfo {
    
    self.cachedAviasalesAdView = nil;
    
    JRAviasalesAdLoader *loader = [[JRAviasalesAdLoader alloc] initWithSearchInfo:searchInfo];
    
    __weak NSMutableSet *loaders = _adLoaders;
    [loaders addObject:loader];
    
    __weak typeof(self) weakself = self;
    [loader loadAdWithCallback:^(UIView *adView) {
        [loaders removeObject:loader];
        weakself.cachedAviasalesAdView = adView;
    }];
}

@end
