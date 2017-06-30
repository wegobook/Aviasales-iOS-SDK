//
//  HLPanGestureRecognizer.m
//  HotelLook
//
//  Created by Oleg on 27/05/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import "HLPanGestureRecognizer.h"

NSInteger const static kDirectionPanThreshold = 5;

@interface HLPanGestureRecognizer ()
{
    BOOL _drag;
    NSInteger _moveX;
    NSInteger _moveY;
}

@end


@implementation HLPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX+= (prevPoint.x - nowPoint.x);
    _moveY+= (prevPoint.y - nowPoint.y);
    
    if (!_drag) {
        if (ABS(_moveX) > kDirectionPanThreshold) {
            if (_direction == HLPanGestureRecognizerDirectionVertical) {
//                self.state = UIGestureRecognizerStateFailed;
            } else {
                _drag = YES;
            }
        } else if (ABS(_moveY) > kDirectionPanThreshold) {
            if (_direction == HLPanGestureRecognizerDirectionHorizontal) {
//                self.state = UIGestureRecognizerStateFailed;
            } else {
                _drag = YES;
            }
        }
    }
}

- (void)reset
{
    [super reset];
    
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
