//
//  JRDatePickerDayView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRDatePickerMonthItem.h"

@interface JRDatePickerDayView : UIButton

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL todayLabelHidden;
@property (assign, nonatomic) BOOL backgroundImageViewHidden;

- (void)setDate:(NSDate *)date monthItem:(JRDatePickerMonthItem *)monthItem;

@end
