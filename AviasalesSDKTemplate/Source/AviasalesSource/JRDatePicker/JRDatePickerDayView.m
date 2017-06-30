//
//  JRDatePickerDayView.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDatePickerDayView.h"
#import "UIImage+JRUIImage.h"
#import "DateUtil.h"
#import "JRColorScheme.h"
#import "ALView+PureLayout.h"

@interface JRDatePickerDayView ()

@property (strong, nonatomic) UILabel *todayLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation JRDatePickerDayView

- (void)setTodayLabelHidden:(BOOL)todayLabelHidden
{
	_todayLabelHidden = todayLabelHidden;
	if (!_todayLabelHidden && !_todayLabel) {
		self.todayLabel = [UILabel new];
		self.todayLabel.text = NSLS(@"JR_DATE_PICKER_TODAY_DATE_TITLE").lowercaseString;
		self.todayLabel.font = [UIFont systemFontOfSize:9];
		self.todayLabel.textColor = [JRColorScheme darkTextColor];
		self.todayLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.todayLabel.textAlignment = NSTextAlignmentCenter;
		self.todayLabel.adjustsFontSizeToFitWidth = YES;
		self.todayLabel.minimumScaleFactor = 0;
        
		UIView *labelSuperView = self;
        
		[labelSuperView addSubview:_todayLabel];
        [self.todayLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:14.0];
        [self.todayLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
	}
	[self updateTodayLabel];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
    
	[self updateHighlight];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateHighlight];
}

- (void)updateHighlight {
    [self updateTodayLabel];
}

- (void)setBackgroundImageViewHidden:(BOOL)hidden {
    if (!hidden) {
        UIImage *image = [[UIImage imageNamed:@"searchFormButton"] imageTintedWithColor:[JRColorScheme mainButtonBackgroundColor]];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:image];
        UIView *bgSuperView = self.superview;
        [bgSuperView insertSubview:self.backgroundImageView belowSubview:self];
        [self.backgroundImageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
        [self.backgroundImageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self];
    } else {
        [self.backgroundImageView removeFromSuperview];
    }
}

- (void)updateTodayLabel {
	BOOL selectedOrHighlighted = self.selected || self.highlighted;
	BOOL shouldHideTodayLabel = selectedOrHighlighted || _todayLabelHidden;
	[_todayLabel setHidden:shouldHideTodayLabel];
}

- (void)setDate:(NSDate *)date monthItem:(JRDatePickerMonthItem *)monthItem {
	_date = date;
	NSString *title = monthItem.stateObject.weeksStrings[date];
	[self setTitle:title forState:UIControlStateNormal];
}

- (NSString *)accessibilityLabel {
    return [DateUtil dayMonthYearStringFromDate:_date];
}

@end
