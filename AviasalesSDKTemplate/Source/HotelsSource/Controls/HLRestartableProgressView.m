#import "HLRestartableProgressView.h"

static NSTimeInterval const animationDuration = 0.3;

@interface HLRestartableProgressView()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, weak) IBOutlet UIView *progressBar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressBarConstraint;
@property (nonatomic, copy) CGFloat (^progressBlock)(void);

@end

@implementation HLRestartableProgressView

- (UIColor *)progressColor
{
    return self.progressBar.backgroundColor;
}

- (void)setProgressColor:(UIColor *)progressBarColor
{
    self.progressBar.backgroundColor = progressBarColor;
}

- (void)startWithProgressBlock:(CGFloat (^)(void))progressBlock
{
    self.progressBlock = progressBlock;

    self.currentProgress = 0.0f;
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    self.progressBarConstraint.constant = 0.0;

    [self setNeedsLayout];
}

- (void)updateProgress
{
    CGFloat progress = self.progressBlock();
    [self progressChanged:progress];
}

- (void)stop
{
    [self progressChanged:1.0];
}

- (void)progressChanged:(CGFloat)progress
{
    if (self.currentProgress > 0.999) {
        self.hidden = self.shouldHideOnCompletion;
        [self.displayLink invalidate];
    } else {
        self.hidden = NO;
    }

    CGFloat delta = (progress - self.currentProgress) * (self.displayLink.duration / animationDuration);
    self.currentProgress += delta;
    self.progressBarConstraint.constant = self.frame.size.width * self.currentProgress;
    [self setNeedsLayout];
}

@end
