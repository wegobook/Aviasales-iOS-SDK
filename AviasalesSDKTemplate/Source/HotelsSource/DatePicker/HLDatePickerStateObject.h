//
//  JRDatePickerStateObject.h
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/02/14.
//
//

#import <Foundation/Foundation.h>
#import "JRDatePickerDayView.h"
#import <HotellookSDK/HotellookSDK.h>

typedef enum {
	modeDeparture,
	modeReturn,
	modeDefault
} HLDatePickerMode;

@protocol HLDatePickerStateObjectActionDelegate<NSObject>
@required
-(void)dateWasSelected:(NSDate *)date;
-(void)showRestrictionToast;
@end

@interface HLDatePickerStateObject : NSObject<NSCopying>

@property (assign, nonatomic) JRDatePickerMode mode;
@property (strong, nonatomic) NSDate *firstAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *lastAvalibleForSearchDate;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *borderDate;
@property (strong, nonatomic) NSDate * firstSelectedDate;
@property (strong, nonatomic) NSDate * secondSelectedDate;
@property (strong, nonatomic) NSMutableArray *monthItems;
@property (strong, nonatomic) NSMutableArray *selectedDates;
@property (strong, nonatomic) NSMutableArray *improperlySelectedDates;
@property (strong, nonatomic) NSIndexPath *indexPathToScroll;
@property (strong, readonly, nonatomic) NSMutableSet *disabledDates;
@property (strong, readonly, nonatomic) NSMutableDictionary *weeksStrings;

@property (weak, nonatomic) id <HLDatePickerStateObjectActionDelegate> delegate;

- (id)initWithDelegate:(id<HLDatePickerStateObjectActionDelegate>)delegate;
- (void)updateSelectedDatesRange;

- (void) selectDate:(NSDate *)date;
- (BOOL) areDatesSelectedProperly;
- (void)restrictCheckoutDate;

@end
