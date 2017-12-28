//
//  JRDatePickerStateObject.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 10/02/14.
//
//

#import "HLDatePickerStateObject.h"
#import "JRDatePickerMonthItem.h"
#import "DateUtil.h"
#import <HotellookSDK/HotellookSDK.h>

@implementation HLDatePickerStateObject

- (id)initWithDelegate:(id<HLDatePickerStateObjectActionDelegate>)delegate
{
	self = [super init];
	if (self) {
        
		_delegate = delegate;
        
		_weeksStrings = [NSMutableDictionary new];
		_disabledDates = [NSMutableSet new];
		_monthItems = [NSMutableArray new];
        
        _firstAvalibleForSearchDate = [DateUtil borderDate];
        _lastAvalibleForSearchDate = [DateUtil nextYearDate:_firstAvalibleForSearchDate];
	}
	return self;
}

- (void)updateSelectedDatesRange
{
	if (_mode != JRDatePickerModeDefault) {
		_selectedDates = [NSMutableArray new];
		self.improperlySelectedDates = [NSMutableArray new];
		if (_firstSelectedDate && _secondSelectedDate) {
			NSDate * dayIn30days = [DateUtil dateIn30Days:self.firstSelectedDate];
			for (JRDatePickerMonthItem *item in _monthItems) {
				for (NSArray *week in item.weeks) {
					for (NSDate *date in week) {
						BOOL lessThanFirstDate = [date compare:_firstSelectedDate] == NSOrderedAscending;
						BOOL moreThanSecondDate = [date compare:_secondSelectedDate] == NSOrderedDescending;
						BOOL moreThan30DaysFromFrirstDate = [HDKDateUtil isDate:dayIn30days beforeDate:date];
						if(!lessThanFirstDate && !moreThanSecondDate && !moreThan30DaysFromFrirstDate){
							[self.selectedDates addObject:date];
						}
						if(!lessThanFirstDate && !moreThanSecondDate && moreThan30DaysFromFrirstDate){
							[self.improperlySelectedDates addObject:date];
						}
					}
				}
			}
		}
		else if(self.firstSelectedDate){
			[self.selectedDates addObject:self.firstSelectedDate];
		}
	}
    
	NSDate *dateForSearch = _mode == JRDatePickerModeDeparture ? _firstSelectedDate : _secondSelectedDate;
	if (!dateForSearch) {
		dateForSearch = _mode == JRDatePickerModeDeparture ? _secondSelectedDate : _firstSelectedDate;
	}
	if (!dateForSearch) {
		dateForSearch = _borderDate;
	}
	if (dateForSearch) {
		for (JRDatePickerMonthItem *item in _monthItems) {
			for (NSArray *week in item.weeks) {
				if ([week containsObject:dateForSearch] &&
				    ![item.prevDates containsObject:dateForSearch] &&
				    ![item.futureDates containsObject:dateForSearch]) {
					_indexPathToScroll = [NSIndexPath indexPathForRow:0 inSection:[_monthItems indexOfObject:item]];
					break;
				}
			}
		}
	}
    
}

#pragma mark -
#pragma mark Private

- (void) setNewDateWithOneDateExisting:(NSDate *)date
{
	if ([DateUtil isSameDayAndMonthAndYear:date with:self.firstSelectedDate]) {
		return;
	}
	if ([HDKDateUtil isDate:date beforeDate:self.firstSelectedDate]) {
		self.firstSelectedDate = date;
	} else{
		self.secondSelectedDate = date;
	}
}

- (void) setNewDateWithBothDatesExisting:(NSDate *)date
{
	_firstSelectedDate = date;
	_secondSelectedDate = nil;
}

#pragma mark -
#pragma mark Public

- (void) selectDate:(NSDate *)date
{
    if ([HDKDateUtil isDate:date beforeDate:self.borderDate]) {
		return;
	}
    
	if (self.firstSelectedDate && self.secondSelectedDate) {
		[self setNewDateWithBothDatesExisting:date];
	} else if (self.firstSelectedDate) {
		[self setNewDateWithOneDateExisting:date];
	} else {
		self.firstSelectedDate = date;
	}

    if (self.firstSelectedDate != nil && self.secondSelectedDate != nil) {
        NSDate *dayIn30Days = [DateUtil dateIn30Days:self.firstSelectedDate];
        if ([HDKDateUtil isDate:dayIn30Days beforeDate:self.secondSelectedDate]) {
            [self.delegate showRestrictionToast];
        }
    }
}

- (BOOL)areDatesSelectedProperly
{
	if (!self.firstSelectedDate) {
		return NO;
	}
	
    if (!self.secondSelectedDate) {
		return NO;
	}
	
    if ([HDKDateUtil isDate:self.firstSelectedDate beforeDate:self.borderDate]) {
		return NO;
	}
	
    if ([HDKDateUtil isDate:self.secondSelectedDate beforeDate:self.firstSelectedDate]) {
		return NO;
	}

	NSDate * dayIn30days = [DateUtil dateIn30Days:self.firstSelectedDate];
	if ([HDKDateUtil isDate:dayIn30days beforeDate:self.secondSelectedDate]) {
		return NO;
	}
    
	return YES;
}

- (void)restrictCheckoutDate
{
    if (self.secondSelectedDate) {
        NSDate *dayIn30Days = [DateUtil dateIn30Days:self.firstSelectedDate];
        if ([HDKDateUtil isDate:dayIn30Days beforeDate:self.secondSelectedDate]) {
            self.secondSelectedDate = dayIn30Days;
        }
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    HLDatePickerStateObject *copy = [[HLDatePickerStateObject alloc] initWithDelegate:self.delegate];

    if (copy != nil) {
        copy.mode = self.mode;
        copy.firstAvalibleForSearchDate = self.firstAvalibleForSearchDate;
        copy.lastAvalibleForSearchDate = self.lastAvalibleForSearchDate;
        copy.today = self.today;
        copy.borderDate = self.borderDate;
        copy.firstSelectedDate = self.firstSelectedDate;
        copy.secondSelectedDate = self.secondSelectedDate;
        copy.monthItems = self.monthItems;
        copy.selectedDates = self.selectedDates;
        copy.improperlySelectedDates = self.improperlySelectedDates;
        copy.indexPathToScroll = self.indexPathToScroll;
    }

    return copy;
}

@end
