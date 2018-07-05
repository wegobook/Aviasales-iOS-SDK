//
//  JRFilterListCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRTableViewCell.h"

@class JRFilterCheckBoxItem;

@interface JRFilterCheckboxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectedIndicator;
@property (weak, nonatomic) IBOutlet UILabel *listItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *listItemDetailLabel;

@property (nonatomic, strong) JRFilterCheckBoxItem *item;

@property (nonatomic, assign) BOOL checked;

@end
