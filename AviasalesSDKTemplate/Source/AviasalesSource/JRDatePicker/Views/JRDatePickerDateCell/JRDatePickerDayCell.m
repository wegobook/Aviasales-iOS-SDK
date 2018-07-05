//
//  JRDatePickerDayCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerDayCell.h"
#import "JRDatePickerMonthItem.h"
#import "NSLayoutConstraint+JRConstraintMake.h"
#import "JRDatePickerDayView.h"
#import "JRViewController.h"
#import "JRColorScheme.h"


static const NSInteger kDateViewTagOffset = 1000;


@interface JRDatePickerDayCell ()

@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) JRDatePickerMonthItem *datePickerItem;

@property (strong, nonatomic) UIColor *dateTextColor;
@property (strong, nonatomic) UIColor *dateSelectedColor;
@property (strong, nonatomic) UIColor *dateDisabledColor;
@property (strong, nonatomic) UIColor *dateHighlightedColor;

@property (strong, nonatomic) UIStackView *stackView;

@end


@implementation JRDatePickerDayCell

- (void)initialSetup {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setBackgroundColor:[UIColor clearColor]];

    [self disableClipForViewSubviews:self];
    
    self.dateTextColor = [JRColorScheme darkTextColor];
    self.dateSelectedColor = [JRColorScheme actionColor];
    self.dateDisabledColor = [JRColorScheme inactiveLightTextColor];
    self.dateHighlightedColor = [JRColorScheme actionColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.stackView = nil;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFillEqually;

        [self.contentView addSubview:_stackView];

        _stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [_stackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [_stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [_stackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
        [_stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    }
    return _stackView;
}

- (JRDatePickerDayView *)dateViewForDate:(NSDate *)date
{
    BOOL shouldHideCell = [_datePickerItem.prevDates containsObject:date] ||
    [_datePickerItem.futureDates containsObject:date];
    
    NSUInteger indexOfDate = [_dates indexOfObject:date];
    NSInteger dateViewTag = indexOfDate + kDateViewTagOffset;
    
    UIView *dateViewSuperview = self.contentView;
    
    id viewWithTag = [dateViewSuperview viewWithTag:dateViewTag];
    JRDatePickerDayView *dateView = viewWithTag;
    
    if (!dateView && !shouldHideCell) {
        dateView =  LOAD_VIEW_FROM_NIB_NAMED(@"JRDatePickerDayView");
        dateView.tag = dateViewTag;
    }
    
    [dateView setTodayLabelHidden:YES];
    [dateView setHidden:shouldHideCell];
    
    if (shouldHideCell) {
        dateView.backgroundImageViewHidden = YES;

        return nil;
    } else {
        return dateView;
    }
}

- (void)setupDateView:(JRDatePickerDayView *)dateView date:(NSDate *)date {
    [dateView setDate:date monthItem:_datePickerItem];
    [dateView addTarget:self action:@selector(dateViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isSelectedDate = [_datePickerItem.stateObject.firstSelectedDate isEqualToDate:date] || [_datePickerItem.stateObject.secondSelectedDate isEqualToDate:date];
    [dateView setSelected:isSelectedDate];
    dateView.backgroundImageViewHidden = !isSelectedDate;

    BOOL enabled = [_datePickerItem.stateObject.disabledDates containsObject:date] &&
    [date compare:_datePickerItem.stateObject.lastAvalibleForSearchDate] == NSOrderedAscending;
    BOOL selected = [_datePickerItem.stateObject.selectedDates containsObject:date];

    if (!enabled) {
        [dateView setTitleColor:self.dateDisabledColor forState:UIControlStateNormal];
    } else if (selected) {
        [dateView setTitleColor:self.dateSelectedColor forState:UIControlStateNormal];
    } else {
        [dateView setTitleColor:self.dateTextColor forState:UIControlStateNormal];
    }

    [dateView setTitleColor:self.dateHighlightedColor forState:UIControlStateHighlighted];

    dateView.enabled = enabled;

    [dateView setTodayLabelHidden:date != _datePickerItem.stateObject.today];
}

- (void)updateCell {
    for (UIButton *button in self.contentView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setHighlighted:NO];
            [button setSelected:NO];
        }
    }

    for (NSDate *date in _dates) {
        JRDatePickerDayView *dateView = [self dateViewForDate:date];
        if (dateView) {
            [self.stackView addArrangedSubview:dateView];
            dateView.backgroundImageViewHidden = YES;
            [self setupDateView:dateView date:date];
        } else {
            [self.stackView addArrangedSubview:[[UIView alloc] initWithFrame:CGRectZero]];
        }
    }
}

- (void)dateViewAction:(JRDatePickerDayView *)dateViewAction {
    [_datePickerItem.stateObject.delegate dateWasSelected:dateViewAction.date];
}

- (void)setDatePickerItem:(JRDatePickerMonthItem *)datePickerItem dates:(NSArray *)dates {
    _dates = dates;
    _datePickerItem = datePickerItem;
    
    [self updateCell];
    
    [self disableClipForViewSubviews:self];
}

- (void)disableClipForViewSubviews:(UIView *)superview {
    [superview setClipsToBounds:NO];
    [superview setOpaque:YES];
    [superview setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *view in superview.subviews) {
        [self disableClipForViewSubviews:view];
    }
}

@end
