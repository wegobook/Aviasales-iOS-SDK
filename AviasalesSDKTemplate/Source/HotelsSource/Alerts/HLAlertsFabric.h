#import <Foundation/Foundation.h>

@class HLRateUsAlertView;
@class HLOutdatedResultsAlertView;
@class HLLocationAlertView;
@class HLAlertView;
@class HLRestartSearchAlertView;
@class HLToastView;
@class HDKSearchInfo;

NS_ASSUME_NONNULL_BEGIN

@interface HLAlertsFabric : NSObject

+ (void)showOutdatedResultsAlert:(void (^ __nullable)(UIAlertAction *action))handler;
+ (void)showSearchAlertViewWithError:(NSError * _Nullable )error handler:(void (^ __nullable)(UIAlertAction *action))handler;
+ (void)showEmptySearchFormAlert:(HDKSearchInfo *)searchInfo inController:(UIViewController *)controller;
+ (void)showMailSenderUnavailableAlertInController:(UIViewController *)controller;
+ (void)showLocationAlert;

+ (HLToastView *)clipboardToast;
+ (HLToastView *)datesRestrictionToast;

@end

NS_ASSUME_NONNULL_END
