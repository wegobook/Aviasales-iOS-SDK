#import <UIKit/UIKit.h>

@class HLToastView;
@class HLAlertView;
@class HLSearchInfo;

@interface HLCommonVC : UIViewController

- (IBAction)goBack;

- (void)addSearchInfoView:(nonnull HLSearchInfo *)searchInfo;
- (void)disableScrollForInteractivePopGesture:(UIScrollView * _Null_unspecified)scrollView;
- (void)showToast:(HLToastView * _Null_unspecified)toast animated:(BOOL)animated;

- (UIView * _Nullable)insetableView;

@end


@interface HLCommonVC (Popover)

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC
                 above:(UIView * _Null_unspecified)anchorView
              distance:(CGFloat)distance
           contentSize:(CGSize)contentSize
       backgroundColor:(UIColor * _Null_unspecified)color;

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC
                 under:(UIView * _Null_unspecified)anchorView
              distance:(CGFloat)distance
           contentSize:(CGSize)contentSize
       backgroundColor:(UIColor * _Null_unspecified)color;

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC
                 above:(UIView * _Null_unspecified)anchorView
              distance:(CGFloat)distance
           contentSize:(CGSize)contentSize
       backgroundColor:(UIColor * _Null_unspecified)color
          cornerRadius:(CGFloat)cornerRadius;

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC
                 under:(UIView * _Null_unspecified)anchorView
              distance:(CGFloat)distance
           contentSize:(CGSize)contentSize
       backgroundColor:(UIColor * _Null_unspecified)color
          cornerRadius:(CGFloat)cornerRadius;

- (void)presentPopover:(UIViewController * _Null_unspecified)contentVC
                 under:(UIView * _Null_unspecified)anchorView
           contentSize:(CGSize)contentSize;

- (void)customPresentVC:(UIViewController * _Nonnull)vc animated:(BOOL)animated;

@end


@interface HLCommonVC (ViewLoading)

- (void)hl_loadView;

@end
