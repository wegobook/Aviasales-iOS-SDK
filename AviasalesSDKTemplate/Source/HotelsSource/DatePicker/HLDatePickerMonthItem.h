//
//  JRDatePickerMonthItem.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import <Foundation/Foundation.h>
#import "HLDatePickerStateObject.h"

@interface HLDatePickerMonthItem : NSObject

@property (weak, nonatomic) HLDatePickerStateObject *stateObject;

@property (strong, readonly, nonatomic) NSMutableArray *prevDates;
@property (strong, readonly, nonatomic) NSMutableArray *futureDates;

@property (strong, readonly, nonatomic) NSMutableArray *weeks;
@property (strong, readonly, nonatomic) NSMutableArray *weekdays;

@property (strong, readonly, nonatomic) NSDate *firstDayOfMonth;

+ (instancetype)monthItemWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(HLDatePickerStateObject *)stateObject;
@end
