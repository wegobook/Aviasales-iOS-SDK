#import "HLAlertsFabric.h"

@implementation HLAlertsFabric

#pragma mark - System alerts

+ (UIAlertController *)showAlertWithText:(NSString *)text title:(NSString *)title inController:(UIViewController *)parentController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:text
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [parentController presentViewController:alertController animated:YES completion:nil];

    return alertController;
}

+ (void)showEmptySearchFormAlert:(HLSearchInfo *)searchInfo inController:(UIViewController *)controller
{
    [self showAlertWithText:[self alertMessage:searchInfo]
                      title:NSLS(@"HL_LOC_SEARCH_FORM_EMPTY_ALERT_TITLE")
               inController:controller];
}

+ (void)showMailSenderUnavailableAlertInController:(UIViewController *)controller
{
    [self showAlertWithText:NSLS(@"HL_LOC_EMAIL_SENDER_UNAVALIBLE_MESSAGE")
                      title:NSLS(@"HL_LOC_EMAIL_SENDER_UNAVALIBLE_TITLE")
               inController:controller];
}

+ (void)showLocationAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLS(@"HL_LOC_NO_CURRENT_CITY_SCREEN_TITLE")
                                                                             message:NSLS(@"HL_LOC_NO_CURRENT_CITY_SCREEN_DESCRIPTION")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLS(@"HL_LOC_ALERT_LATER_BUTTON") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLS(@"HL_LOC_NO_CURRENT_CITY_SETTINGS_BUTTON")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                     }];
    [alertController addAction:settings];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showSearchAlertViewWithError:(NSError * _Nullable )error handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    if (error.code == NSURLErrorNotConnectedToInternet) {
        [HLAlertsFabric showNoInternetConnectionAlert:handler];
    } else {
        [HLAlertsFabric showSearchErrorAlert:handler];
    }
}

+ (void)showSearchErrorAlert:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLS(@"HL_ALERT_SEARCH_ERROR_TITLE")
                                                                             message:NSLS(@"HL_ALERT_SEARCH_ERROR_DESCRIPTION")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLS(@"HL_LOC_ALERT_CLOSE_BUTTON") style:UIAlertActionStyleDefault handler:handler];
    [alertController addAction:ok];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showNoInternetConnectionAlert:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLS(@"HL_ALERT_NO_INTERNET_CONNECTION_TITLE")
                                                                             message:NSLS(@"HL_ALERT_NO_INTERNET_CONNECTION_DESCRIPTION")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLS(@"HL_LOC_ALERT_CLOSE_BUTTON") style:UIAlertActionStyleDefault handler:handler];
    [alertController addAction:ok];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showOutdatedResultsAlert:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLS(@"HL_ALERT_OUTDATED_RESULTS_TITLE")
                                                                             message:NSLS(@"HL_ALERT_OUTDATED_RESULTS_DESCRIPTION")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLS(@"HL_LOC_ALERT_LATER_BUTTON") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    UIAlertAction *newSearch = [UIAlertAction actionWithTitle:NSLS(@"HL_NEW_SEARCH_BUTTON")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    [alertController addAction:newSearch];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Toasts

+ (HLToastView *)clipboardToast
{
    NSString *text = NSLS(@"HL_LOC_SHARE_COPIED_TO_CLIPBOARD");
    UIImage *image = [UIImage toastCheckMarkIcon];
    HLToastView *toastView = [self toastWithText:text icon:image];
    toastView.userInteractionEnabled = NO;
    return toastView;
}

+ (HLToastView *)datesRestrictionToast
{
    NSString *text = NSLS(@"HL_LOC_DATE_PICKER_LENGTH_RESTRICTION_TITLE");
    UIImage *image = [UIImage imageNamed:@"toastCrossIcon"];
    return [self toastWithText:text icon:image];
}

#pragma mark - Private

+ (HLToastView *)toastWithText:(NSString *)text icon:(UIImage *)image
{
    HLToastView *tv = LOAD_VIEW_FROM_NIB_NAMED(@"HLToastView");
    tv.titleLabel.text = text;
    tv.iconView.image = image;
    tv.hideAfterTime = 2.0;
    return tv;
}

+ (NSString *)alertMessage:(HLSearchInfo *)searchInfo
{
    if (searchInfo.adultsCount <= 0) {
        return NSLS(@"HL_LOC_SEARCH_FORM_EMPTY_ADULTS_MESSAGE");
    }
    if (searchInfo.checkInDate == nil || searchInfo.checkOutDate == nil) {
        return NSLS(@"HL_LOC_SEARCH_FORM_EMPTY_DATES_MESSAGE");
    }
    if (searchInfo.city == nil && searchInfo.hotel == nil) {
        return NSLS(@"HL_LOC_SEARCH_FORM_EMPTY_CITY_MESSAGE");
    }
    return NSLS(@"HL_LOC_SEARCH_FORM_EMPTY_CITY_MESSAGE");
}

@end
