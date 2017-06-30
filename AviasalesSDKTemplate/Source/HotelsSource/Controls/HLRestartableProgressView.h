#import <UIKit/UIKit.h>

@interface HLRestartableProgressView : UIView

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign) BOOL shouldHideOnCompletion;

- (void)startWithProgressBlock:(CGFloat (^)(void))progressBlock;
- (void)stop;

@end
