#import "HLDeceleratingProgressAnimator.h"

@interface HLDeceleratingProgressAnimator ()
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval elapsedTime;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat stoppedAtProgress;
@end


@implementation HLDeceleratingProgressAnimator

- (void)startWithDuration:(NSTimeInterval)duration
{
    self.progress = 0.0;
    self.elapsedTime = 0.0;
    self.animationDuration = duration;

    [self.displayLink invalidate];

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopWithDuration:(NSTimeInterval)duration
{
    [self.displayLink invalidate];

    self.stoppedAtProgress = self.progress;

    self.elapsedTime = 0.0;
    self.animationDuration = duration;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(finishProgress)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateProgress
{
    self.elapsedTime += self.displayLink.duration;
    self.progress = 0.95 * atan(self.elapsedTime / self.animationDuration * 2.0) / M_PI_2;
}

- (void)finishProgress
{
    self.elapsedTime += self.displayLink.duration;
    self.progress = MAX(0.0, MIN(self.stoppedAtProgress + (1.0 - self.stoppedAtProgress) * self.elapsedTime / self.animationDuration, 1.0));
    
    if (self.progress >= 1.0) {
        [self.displayLink invalidate];
    }
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration = animationDuration;

    if (_animationDuration < FLT_EPSILON) {
        _animationDuration = FLT_EPSILON;
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self.delegate progressChanged:progress];
}


@end
