//
//  JRFilterCheckboxCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterCheckboxCell.h"

#import "JRFilterCheckBoxItem.h"
#import "JRColorScheme.h"

@implementation JRFilterCheckboxCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0.0, 44.0, 0.0, 0.0);
    
    self.listItemLabel.numberOfLines = 3;
    self.listItemDetailLabel.textColor = [JRColorScheme darkTextColor];
    
    self.selectedIndicator.tintColor = [JRColorScheme mainColor];
}

#pragma - mark Public methds

- (void)setItem:(JRFilterCheckBoxItem *)item {
    _item = item;
    _checked = item.selected;
    
    self.listItemLabel.text = item.title;
    self.listItemDetailLabel.attributedText = item.attributedStringValue;
    self.selectedIndicator.selected = item.selected;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    
    self.selectedIndicator.selected = checked;
    
    self.item.selected = checked;
    self.item.filterAction();
}

@end
