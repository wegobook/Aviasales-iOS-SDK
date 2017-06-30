//
//  ASTComplexSearchFormHeaderView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTComplexSearchFormHeaderView.h"

@interface ASTComplexSearchFormHeaderView ()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation ASTComplexSearchFormHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadViewFromNib];
    }
    return self;
}

- (void)loadViewFromNib {
    self.view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
}

@end
