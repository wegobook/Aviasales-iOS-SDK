#import "HLCommonVC.h"
#import <objc/runtime.h>
#import "NSObject+Notifications.h"
#import "Collections+HLNibLoading.h"
#import <PureLayout/PureLayout.h>
#import "HLAlertsFabric.h"

@interface HLCommonVC () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) CGFloat popoverDistanceToAnchorView;
@property (nonatomic, assign) BOOL didSetupInitialConstraints;
@property (nonatomic, assign) BOOL shouldSetCustomTopLayoutGuide;
@property (nonatomic, assign) CGFloat customTopLayoutGuideLength;

@end

@implementation HLCommonVC

#pragma mark - view lifecycle

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (iPad() ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return (iPad() ? [super preferredInterfaceOrientationForPresentation] : UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [self unregisterNotificationResponse];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [JRColorScheme mainBackgroundColor];
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
}

#pragma mark - Public

- (void)showToast:(HLToastView *)toast animated:(BOOL)animated
{
    [toast show:self.view animated:animated];
}

- (IBAction)goBack
{
    [self popOrDismissBasedOnDeviceTypeWithAnimated:YES];
}

- (void)disableScrollForInteractivePopGesture:(UIScrollView *)scrollView
{
    UIGestureRecognizer *rec = self.navigationController.interactivePopGestureRecognizer;
    if (rec) {
        [scrollView.panGestureRecognizer requireGestureRecognizerToFail:rec];
    }
}

- (void)addSearchInfoView:(HLSearchInfo *)searchInfo
{
    HLSearchInfoNavBarView *view = [HLSearchInfoNavBarView new];
    [view configureForSearchInfo:searchInfo];
    [view setupConstraints];
    CGSize limits = CGSizeMake(375.0, 35.0);
    CGSize size = [view systemLayoutSizeFittingSize:limits];
    view.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    self.navigationItem.titleView = view;
}

#pragma mark - Navbar setup

- (UIView *)insetableView
{
    UIView *result;

    if ([self respondsToSelector:@selector(tableView)]) {
        result = [self performSelector:@selector(tableView)];
    } else if ([self respondsToSelector:@selector(collectionView)]) {
        result = [self performSelector:@selector(collectionView)];
    } else if ([self respondsToSelector:@selector(mapView)]) {
        result = [self performSelector:@selector(mapView)];
    }

    return result;
}

#pragma mark - Private

- (BOOL)isRootViewController
{
    if (self.navigationController.viewControllers.count == 0) {
        return YES;
    }

    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        return YES;
    }

    return NO;
}

- (UIEdgeInsets)popoverEdgeInsets
{
    return UIEdgeInsetsMake(20.0, 20.0, 0.0, 20.0);
}

- (void)setCornerRadius:(CGFloat)cornerRadius recursiveFor:(UIView *)view
{
    view.layer.cornerRadius = cornerRadius;

    if (view.superview) {
        [self setCornerRadius:cornerRadius recursiveFor:view.superview];
    }
}

- (CGRect)popoverSourceRectFrameWithAnchorView:(UIView *)anchorView
{
    CGFloat deltaY = self.popoverDistanceToAnchorView;
    CGRect rect = CGRectMake(0.0, deltaY, anchorView.frame.size.width, anchorView.frame.size.height);

    return rect;
}

#pragma mark - UIPopoverPresentationControllerDelegate methods

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController
          willRepositionPopoverToRect:(inout CGRect *)rect
                               inView:(inout UIView **)view
{
    popoverPresentationController.sourceRect = [self popoverSourceRectFrameWithAnchorView:popoverPresentationController.sourceView];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

@end

@implementation HLCommonVC (Popover)

- (void)presentPopover:(UIViewController *)contentVC above:(UIView *)anchorView distance:(CGFloat)distance contentSize:(CGSize)contentSize backgroundColor:(UIColor *)color
{
    [self presentPopover:contentVC from:anchorView distance:(CGFloat)distance permittedArrowDirections:UIPopoverArrowDirectionDown contentSize:contentSize backgroundColor:color];
}

- (void)presentPopover:(UIViewController *)contentVC under:(UIView *)anchorView distance:(CGFloat)distance contentSize:(CGSize)contentSize backgroundColor:(UIColor *)color
{
    [self presentPopover:contentVC from:anchorView distance:(CGFloat)distance permittedArrowDirections:UIPopoverArrowDirectionUp contentSize:contentSize backgroundColor:color];
}

- (void)presentPopover:(UIViewController *)contentVC above:(UIView *)anchorView distance:(CGFloat)distance contentSize:(CGSize)contentSize backgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    [self presentPopover:contentVC from:anchorView distance:(CGFloat)distance permittedArrowDirections:UIPopoverArrowDirectionDown contentSize:contentSize backgroundColor:color cornerRadius:cornerRadius];
}

- (void)presentPopover:(UIViewController *)contentVC under:(UIView *)anchorView distance:(CGFloat)distance contentSize:(CGSize)contentSize backgroundColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    [self presentPopover:contentVC from:anchorView distance:(CGFloat)distance permittedArrowDirections:UIPopoverArrowDirectionUp contentSize:contentSize backgroundColor:color cornerRadius:cornerRadius];
}

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC under:(UIView * _Null_unspecified)anchorView contentSize:(CGSize)contentSize
{
    [self presentPopover:contentVC under:anchorView distance:-6 contentSize:contentSize backgroundColor:[JRColorScheme lightBackgroundColor] cornerRadius:20.0];
}

- (void)presentPopover:(UIViewController *)contentVC from:(UIView *)anchorView distance:(CGFloat)distance permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections contentSize:(CGSize)contentSize backgroundColor:(UIColor *)color
{
    [self presentPopover:contentVC from:anchorView distance:(CGFloat)distance permittedArrowDirections:permittedArrowDirections contentSize:contentSize backgroundColor:color cornerRadius:5.0f];
}

- (void)presentPopover:(UIViewController *)contentVC
                  from:(UIView *)anchorView
              distance:(CGFloat)distance
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
           contentSize:(CGSize)contentSize
       backgroundColor:(UIColor *)color
          cornerRadius:(CGFloat)cornerRadius
{
    UIEdgeInsets insets = [self popoverEdgeInsets];

    BOOL isUpDirection = permittedArrowDirections & UIPopoverArrowDirectionUp;
    self.popoverDistanceToAnchorView = isUpDirection ? distance : -distance;

    contentVC.modalPresentationStyle = UIModalPresentationPopover;
    contentVC.preferredContentSize = contentSize;

    UIPopoverPresentationController *presentationController = contentVC.popoverPresentationController;
    presentationController.delegate = self;
    presentationController.popoverLayoutMargins = insets;
    presentationController.sourceRect = [self popoverSourceRectFrameWithAnchorView:anchorView];
    presentationController.sourceView = anchorView;
    presentationController.permittedArrowDirections = permittedArrowDirections;
    presentationController.backgroundColor = color;

    [self presentViewController:contentVC animated:YES completion:^{
        [self setCornerRadius:cornerRadius recursiveFor:contentVC.view.superview];
    }];
}

- (void)customPresentVC:(UIViewController *)vc animated:(BOOL)animated
{
    JRNavigationController *navVC = [[JRNavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLS(@"JR_CLOSE_BUTTON_TITLE")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(dismiss)];
    
    [self presentViewController:navVC animated:animated completion:nil];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation HLCommonVC (ViewLoading)

- (void)hl_loadView
{
    if ([self respondsToSelector:@selector(loadViewIfNeeded)]) {
        [self loadViewIfNeeded];
    } else {
        [self view];
    }
}

@end
