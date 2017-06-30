//
//  JRDatePickerMonthItem.m
//  Aviasales iOS Apps
//
//  Created by Ruslan Shevchuk on 05/02/14.
//
//

#import "HLDatePickerMonthItem.h"
#import "DateUtil.h"

@implementation HLDatePickerMonthItem

+ (id)monthItemWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(HLDatePickerStateObject *)stateObject
{
	return [[HLDatePickerMonthItem alloc] initWithFirstDateOfMonth:firstDayOfMonth stateObject:stateObject];
}

- (id)initWithFirstDateOfMonth:(NSDate *)firstDayOfMonth stateObject:(HLDatePickerStateObject *)stateObject
{
	self = [super init];
	if (self) {
		_stateObject = stateObject;
		_firstDayOfMonth = firstDayOfMonth;
		[self prepareDatesForCurrrentMonth];
	}
	return self;
}

- (NSMutableArray *)getPreviousDates:(NSDate *)firstDate count:(NSInteger)count
{
	NSMutableArray *prevDates = [[NSMutableArray alloc] init];
    
	for (NSInteger i = 0; i < count; i++) {
		NSDate *prevDate = prevDates.count ?[prevDates firstObject] : firstDate;
		NSDate *newDate = [DateUtil prevDayForDate:prevDate];
		[prevDates insertObject:newDate atIndex:0];
	}
	return prevDates;
}

- (NSMutableArray *)getDatesInThisMonth
{
	NSMutableArray *datesThisMonth = [[NSMutableArray alloc] init];
    
	NSRange rangeOfDaysThisMonth = [[HDKDateUtil sharedCalendar]
	                                rangeOfUnit:NSCalendarUnitDay
	                                inUnit:NSCalendarUnitMonth
	                                forDate:_firstDayOfMonth];
    
	unsigned unitFlags = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra);
	NSDateComponents *components = [[HDKDateUtil sharedCalendar] components:unitFlags fromDate:_firstDayOfMonth];
    
	for (NSInteger i = rangeOfDaysThisMonth.location; i < NSMaxRange(rangeOfDaysThisMonth); ++i) {
		[components setDay:i];
		NSDate *dayInMonth = [[HDKDateUtil sharedCalendar] dateFromComponents:components];
		[datesThisMonth addObject:dayInMonth];
	}
	return datesThisMonth;
}

- (NSMutableArray *)getFutureDatesForLastWeek:(NSArray *)lastWeek
{
	NSMutableArray *futureDates = [[NSMutableArray alloc] init];
	for (NSInteger i = lastWeek.count; i < 7; i++) {
		NSDate *newDate = futureDates.count ?
        [DateUtil nextDayForDate:[futureDates lastObject]] :[DateUtil firstDayOfNextMonthForDate:_firstDayOfMonth];
		[futureDates addObject:newDate];
	}
    
	return futureDates;
}

- (NSMutableDictionary *)getWeeksForDatesInFinalArray:(NSMutableArray *)finalArray
{
	NSMutableDictionary *weeks = [NSMutableDictionary new];
	NSNumber *weekCount = @0;
	for (NSDate *day in finalArray) {
		NSMutableArray *week = weeks[[weekCount stringValue]];
		if (![weekCount integerValue]) {
            
            static NSDateFormatter *formatter;
            if (formatter == nil) {
                formatter = [NSDateFormatter new];
            }
            
			[formatter setDateFormat:@"EE"];
			[_weekdays addObject:[[formatter stringFromDate:day] capitalizedString]];
		}
		if (!week) {
			week = [[NSMutableArray alloc] init];
			weeks[[weekCount stringValue]] = week;
		}
		[week addObject:day];
        
		if (week.count == 7) {
			weekCount = @([weekCount integerValue] + 1);
		}
	}
    
	NSMutableArray *lastWeek = weeks[[weekCount stringValue]];
    
	if (lastWeek.count != 7) {
		_futureDates = [self getFutureDatesForLastWeek:lastWeek];
		[lastWeek addObjectsFromArray:_futureDates];
	}
    
	return weeks;
}

- (void)setupDatePickerItemWithWeeksDictionary:(NSMutableDictionary *)weeksDictionary
{
	_weeks = [NSMutableArray new];
    
	NSArray *weekKeys = [[weeksDictionary allKeys] sortedArrayUsingComparator: ^NSComparisonResult (NSString *a, NSString *b) {
        return [a caseInsensitiveCompare:b];
    }];
	for (NSString *key in weekKeys) {
		[_weeks addObject:weeksDictionary[key]];
	}
    
	NSDate *today = [DateUtil systemTimeZoneResetTimeForDate:[NSDate date]];
    
	for (NSArray *week in _weeks) {
		for (NSDate *date in week) {
			if (![_prevDates containsObject:date] && ![_futureDates containsObject:date]) {
				if (!_stateObject.today && [date compare:today] == NSOrderedSame) {
					_stateObject.today = date;
				}
				(_stateObject.weeksStrings)[date] = [DateUtil dayNumberFromDate:date];
				
                NSComparisonResult borderCompare = [_stateObject.borderDate compare:date];
				if (borderCompare == NSOrderedSame) {
					_stateObject.borderDate = date;
				}
				if (borderCompare != NSOrderedDescending) {
					[_stateObject.disabledDates addObject:date];
				}
			}
		}
	}
}

- (void)prepareDatesForCurrrentMonth
{
	NSMutableArray *datesInThisMonth = [self getDatesInThisMonth];
    
	NSDate *firstDate = [datesInThisMonth firstObject];
	NSInteger firstWeekday = [[[HDKDateUtil sharedCalendar] components:NSCalendarUnitWeekday fromDate:firstDate] weekday];
    NSInteger weekStartWeekday = [[HDKDateUtil sharedCalendar] firstWeekday];
    NSInteger prevDatesCount = firstWeekday >= weekStartWeekday ? firstWeekday - weekStartWeekday : 7 - (weekStartWeekday - firstWeekday);
    
    _prevDates = [self getPreviousDates:firstDate count:prevDatesCount];
	NSMutableArray *finalArray = [[NSMutableArray alloc] initWithArray:_prevDates];
	[finalArray addObjectsFromArray:datesInThisMonth];
    
    
	_weekdays = [[NSMutableArray alloc] init];
    
	NSMutableDictionary *weeksDictionary = [self getWeeksForDatesInFinalArray:finalArray];
    
	[self setupDatePickerItemWithWeeksDictionary:weeksDictionary];
}

@end
