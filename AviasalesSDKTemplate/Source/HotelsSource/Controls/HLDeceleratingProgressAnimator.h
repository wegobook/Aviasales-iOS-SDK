#import <UIKit/UIKit.h>

@protocol HLDeceleratingProgressAnimatorDelegate <NSObject>

- (void)progressChanged:(CGFloat)progress;

@end

@interface HLDeceleratingProgressAnimator : NSObject

@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, weak) id<HLDeceleratingProgressAnimatorDelegate> delegate;

- (void)startWithDuration:(NSTimeInterval)duration;
- (void)stopWithDuration:(NSTimeInterval)duration;

@end
