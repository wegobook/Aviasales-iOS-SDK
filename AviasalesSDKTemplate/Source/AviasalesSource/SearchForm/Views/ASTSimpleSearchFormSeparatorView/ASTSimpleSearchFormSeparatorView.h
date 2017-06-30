//
//  ASTSimpleSearchFormSeparatorView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ASTSearchFormSeparatorViewStyle) {
    ASTSearchFormSeparatorViewStyleTop,
    ASTSearchFormSeparatorViewStyleBottom
};

@interface ASTSimpleSearchFormSeparatorView : UIView

@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, assign) CGFloat leftInset;
@property (nonatomic, assign) CGFloat rightInset;
@property (nonatomic, assign) ASTSearchFormSeparatorViewStyle style;

@end
