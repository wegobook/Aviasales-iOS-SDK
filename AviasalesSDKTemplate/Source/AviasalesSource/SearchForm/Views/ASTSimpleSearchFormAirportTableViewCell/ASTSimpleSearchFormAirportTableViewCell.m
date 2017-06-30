//
//  ASTSimpleSearchFormAirportTableViewCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTSimpleSearchFormAirportTableViewCell.h"

@implementation ASTSimpleSearchFormAirportTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImageView.tintColor = [JRColorScheme searchFormTintColor];
}

@end
