#import "HLExtendedAreaSlider.h"

@implementation HLExtendedAreaSlider

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    return CGRectContainsPoint(CGRectInset(self.bounds, 0, -10), point);
}

@end
