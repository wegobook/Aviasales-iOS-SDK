//
//  ASFilterCellWithOneThumbSlider.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterCellWithOneThumbSlider.h"
#import "JRFilterOneThumbSliderItem.h"

@implementation JRFilterCellWithOneThumbSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 0.0);
    
    self.cellSlider.tintColor = [JRColorScheme mainColor];
    
    self.cellLabel.textColor = [JRColorScheme darkTextColor];
    self.cellAttLabel.textColor = [JRColorScheme darkTextColor];
}

#pragma mark - Public methds

- (void)setItem:(JRFilterOneThumbSliderItem *)item {
    
    _item = item;
    
    self.cellSlider.minimumValue = item.minValue;
    self.cellSlider.maximumValue = item.maxValue;
    self.cellSlider.value = item.currentValue;
    
    self.cellAttLabel.attributedText = [item attributedStringValue];
    self.cellLabel.text = [item title];
}

#pragma mark - Actions

- (IBAction)valueDidChanged:(id)sender {
    
    self.item.currentValue = self.cellSlider.value;
    self.item.filterAction();
    
    self.cellAttLabel.attributedText = [self.item attributedStringValue];
}

@end
