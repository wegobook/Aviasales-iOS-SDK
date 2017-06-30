//
//  ASTSimpleSearchFormSeparatorView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTSimpleSearchFormSeparatorView.h"

@implementation ASTSimpleSearchFormSeparatorView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.separatorColor set];
    CGFloat y = self.style == ASTSearchFormSeparatorViewStyleTop ? CGRectGetMinY(self.bounds) : CGRectGetMaxY(self.bounds);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 1.0 * [UIScreen mainScreen].scale);
    CGContextMoveToPoint(currentContext, self.leftInset, y);
    CGContextAddLineToPoint(currentContext, CGRectGetWidth(self.bounds) - self.rightInset, y);
    CGContextStrokePath(currentContext);
}

@end
