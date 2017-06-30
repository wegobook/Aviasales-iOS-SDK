//
//  JRDatePickerStateObject.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>
#import "JRDatePickerEnums.h"


@protocol JRDatePickerStateObjectActionDelegate<NSObject>

-(void)dateWasSelected:(NSDate *)date;

@end


@interface JRDatePickerStateObject : NSObject

@property (assign, nonatomic) JRDatePickerMode mode;
@property (strong, nonatomic) NSDate *firstAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *lastAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *borderDate;
@property (strong, nonatomic) NSDate *firstSelectedDate;
@property (strong, nonatomic) NSDate *secondSelectedDate;
@property (strong, nonatomic) NSMutableArray *monthItems;
@property (strong, nonatomic) NSMutableArray *selectedDates;
@property (strong, nonatomic) NSIndexPath *indexPathToScroll;
@property (strong, readonly, nonatomic) NSMutableArray *disabledDates;
@property (strong, readonly, nonatomic) NSMutableDictionary *weeksStrings;

@property (weak, nonatomic, readonly) id <JRDatePickerStateObjectActionDelegate> delegate;

- (id)initWithDelegate:(id<JRDatePickerStateObjectActionDelegate>)delegate;

- (void)updateSelectedDatesRange;

@end
