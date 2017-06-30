//
//  UIView+Nib.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "UIView+Nib.h"

@implementation UIView (Nib)

+ (instancetype)loadFromNib {
    NSArray <NSString *> *componets = [NSStringFromClass(self) componentsSeparatedByString:@"."];
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:componets.lastObject owner:nil options:nil];
    return [array firstObject];
}

@end
