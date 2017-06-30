//
//  ASTComplexSearchFormFooterView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTComplexSearchFormFooterView.h"

@interface ASTComplexSearchFormFooterView ()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation ASTComplexSearchFormFooterView

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

- (void)awakeFromNib {
    [super awakeFromNib];
    self.addButton.layer.cornerRadius = self.removeButton.layer.cornerRadius = 4.0;
    self.addButton.layer.borderWidth = self.removeButton.layer.borderWidth = 1.0;
    self.addButton.tintColor = self.removeButton.tintColor = [JRColorScheme searchFormTintColor];
    self.addButton.layer.borderColor = self.removeButton.layer.borderColor = [JRColorScheme searchFormTintColor].CGColor;
}

#pragma mark - Actions

- (IBAction)addButtonTapped:(UIButton *)sender {
    if (self.addAction) {
        self.addAction(sender);
    }
}

- (IBAction)removeButtonTapped:(UIButton *)sender {
    if (self.removeAction) {
        self.removeAction(sender);
    }
}

@end
