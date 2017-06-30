#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>

#import "HLResultVariant.h"
#import "HLMailComposeVC.h"

@interface HLEmailSender : NSObject <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) HLMailComposeVC *mailer;
@property (nonatomic, weak) id<MFMailComposeViewControllerDelegate> delegate;

- (void)sendFeedbackEmailTo:(NSString *)email;

+ (BOOL)canSendEmail;
+ (void)showUnavailableAlertInController:(UIViewController *)controller;
@end
