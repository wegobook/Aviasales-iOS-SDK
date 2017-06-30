#import "HLTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface HLTapGestureRecognizer ()
{
	BOOL _didMove;
	BOOL _started;
}

@end


@implementation HLTapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];

    _didMove = NO;
    
    if ([self.delegate gestureRecognizerShouldBegin:self]) {
		[self.stateDelegate recognizerStarted];
		
        _started = YES;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
    if (_started) {
		[self.stateDelegate recognizerCancelled];
	}
	
    _started = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGPoint previousLocation = [touch previousLocationInView:self.view];
    if (!CGPointEqualToPoint(location, previousLocation)) {
        if (_started) {
            [self.stateDelegate recognizerCancelled];
            
            _didMove = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
    if (_didMove) {
		[self.stateDelegate recognizerCancelled];
	} else if (_started) {
		[self.stateDelegate recognizerFinished];
	}
    
	_started = NO;
}

@end
