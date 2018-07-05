//
//  ASTSimpleSearchFormDateTableViewCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTSimpleSearchFormDateTableViewCell.h"

@implementation ASTSimpleSearchFormDateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.iconImageView transformRTL];
    self.iconImageView.tintColor = [JRColorScheme searchFormTintColor];
    self.returnButton.tintColor = [JRColorScheme searchFormTintColor];
    self.returnLabel.textColor = [JRColorScheme searchFormTintColor];
}

- (IBAction)returnButtonTapped:(UIButton *)sender {
    if (self.returnButtonAction) {
        self.returnButtonAction(sender);
    }
}

@end
