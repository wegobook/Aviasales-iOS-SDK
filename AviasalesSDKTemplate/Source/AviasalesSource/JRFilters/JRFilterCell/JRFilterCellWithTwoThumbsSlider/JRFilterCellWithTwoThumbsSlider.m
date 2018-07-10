//
//  ASFilterCellWithTwoThumbsSlider.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterCellWithTwoThumbsSlider.h"
#import "JRFilterTwoThumbSliderItem.h"
#import "NMRangeSlider.h"

@interface JRFilterCellWithTwoThumbsSlider ()

@property (strong, nonatomic) NSLayoutConstraint *dayTimeButtonWidthContraint;

@end

@implementation JRFilterCellWithTwoThumbsSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 0.0);
    
    self.cellSlider.tintColor = [JRColorScheme mainColor];

    self.cellLabel.textColor = [JRColorScheme darkTextColor];
    self.cellAttLabel.textColor = [JRColorScheme darkTextColor];
    
    [self setDayTimeButtonWidthMultiplier:1.0f/4.0f];
    
    for (UIButton *dayTimeButton in self.dayTimeButtons) {
        [dayTimeButton setTitleColor:[JRColorScheme mainColor] forState:UIControlStateNormal];
        dayTimeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        dayTimeButton.titleLabel.minimumScaleFactor = 0.5;
        dayTimeButton.layer.borderColor = [JRColorScheme mainColor].CGColor;
        dayTimeButton.layer.borderWidth = JRPixel();
    }

    [self.cellSlider transformRTL];
}

- (void)setItem:(JRFilterTwoThumbSliderItem *)item {
    
    _item = item;

    self.cellSlider.minimumValue = 0;
    self.cellSlider.maximumValue = item.maxValue - item.minValue;
    /* Bug in NMRangeSlider. Should set upperValue before lowerValue
     https://github.com/muZZkat/NMRangeSlider/issues/39
     */
    self.cellSlider.upperValue = item.currentMaxValue - item.minValue;
    self.cellSlider.lowerValue = item.currentMinValue - item.minValue;
    self.cellSlider.minimumRange = (self.cellSlider.maximumValue - self.cellSlider.minimumValue) / 10;
    
    if (item.needDayTimeShowButtons) {
        [self setupDayTimeButtons];
    } else {
        for (UIButton *button in self.dayTimeButtons) {
            button.hidden = !item.needDayTimeShowButtons;
            button.enabled = item.needDayTimeShowButtons;
        }
    }
    
    self.cellLabel.text = [item title];
    self.cellAttLabel.attributedText = [item attributedStringValue];
}

#pragma - mark Private methds

- (UIButton *)morningButton {
    return self.dayTimeButtons[0];
}

- (UIButton *)dayButton {
    return self.dayTimeButtons[1];
}

- (UIButton *)eveningButton {
    return self.dayTimeButtons[2];
}

- (void)setupDayTimeButtons {
    NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:self.item.minValue];
    NSDate *maxDate = [NSDate dateWithTimeIntervalSince1970:self.item.maxValue];
    NSDateComponents *minComponent = [DateUtil componentsFromDate:minDate];
    NSDateComponents *maxComponent = [DateUtil componentsFromDate:maxDate];
    
    [self.morningButton setTitle:NSLS(@"JR_FILTER_DAY_TIME_MORNING") forState:UIControlStateNormal];
    [self.dayButton setTitle:NSLS(@"JR_FILTER_DAY_TIME_DAY") forState:UIControlStateNormal];
    [self.eveningButton setTitle:NSLS(@"JR_FILTER_DAY_TIME_EVENING") forState:UIControlStateNormal];
    self.morningButton.hidden = self.dayButton.hidden = self.eveningButton.hidden = NO;
    self.morningButton.enabled = self.dayButton.enabled = self.eveningButton.enabled = NO;
    
    if (minComponent.hour >= 0 && minComponent.hour < 11 && maxComponent.hour >= 19 && maxComponent.hour <= 23) {
        self.morningButton.enabled = YES;
        self.dayButton.enabled = YES;
        self.eveningButton.enabled = YES;
    } else if (minComponent.hour >= 0 && minComponent.hour < 10 && maxComponent.hour >= 11 && maxComponent.hour < 19) {
        self.morningButton.enabled = YES;
        self.dayButton.enabled = YES;
    } else if (minComponent.hour >= 11 && minComponent.hour < 18 && maxComponent.hour >= 19 && maxComponent.hour <= 23) {
        self.dayButton.enabled = YES;
        self.eveningButton.enabled = YES;
    }
    
    [self updateDayTimeButtons];
}

- (void)setDayTimeButtonWidthMultiplier:(CGFloat)multiplier {
    if (self.dayTimeButtonWidthContraint != nil) {
        [self.contentView removeConstraint:self.dayTimeButtonWidthContraint];
        self.dayTimeButtonWidthContraint = nil;
    }
    
    if (self.cellSlider != nil) {
        self.dayTimeButtonWidthContraint = JRConstraintMake([self.dayTimeButtons objectAtIndex:1], NSLayoutAttributeWidth, NSLayoutRelationGreaterThanOrEqual, self.contentView, NSLayoutAttributeWidth, multiplier, 0);
        [self.contentView addConstraint:self.dayTimeButtonWidthContraint];
    }
}

- (IBAction)onDayTimeButtonsClicked:(id)sender {
    if (sender == self.morningButton) {
        [self setMorningDeparture];
    } else if (sender == self.dayButton) {
        [self setDayDeparture];
    } else if (sender == self.eveningButton) {
        [self setEveningDeparture];
    }
    
    [self sliderValueChanged:self.cellSlider];
}

- (IBAction)sliderValueChanged:(NMRangeSlider *)sender {
    
    self.item.currentMinValue = (NSTimeInterval)self.cellSlider.lowerValue + self.item.minValue;
    self.item.currentMaxValue =  (NSTimeInterval)self.cellSlider.upperValue + self.item.minValue;
    self.item.filterAction();
    
    self.cellAttLabel.attributedText = [self.item attributedStringValue];
    [self updateDayTimeButtons];
}

- (void)updateDayTimeButtons {
    NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:self.item.minValue];
    NSDateComponents *morningBorderComponents = [DateUtil componentsFromDate:minDate];
    morningBorderComponents.hour = 12;
    morningBorderComponents.minute = 0;
    NSDate *morningBorderDate = [DateUtil dateFromComponents:morningBorderComponents];
    
    NSDateComponents *eveningBorderComponents = [DateUtil componentsFromDate:minDate];
    eveningBorderComponents.hour = 18;
    eveningBorderComponents.minute = 0;
    NSDate *eveningBorderDate = [DateUtil dateFromComponents:eveningBorderComponents];
    
    if (self.morningButton.enabled) {
        self.morningButton.selected = self.item.currentMaxValue < morningBorderDate.timeIntervalSince1970;
    }
    if (self.dayButton.enabled) {
        self.dayButton.selected = (self.item.currentMaxValue < eveningBorderDate.timeIntervalSince1970) && (self.item.currentMinValue >= morningBorderDate.timeIntervalSince1970);
    }
    if (self.eveningButton.enabled) {
        self.eveningButton.selected = self.item.currentMinValue >= eveningBorderDate.timeIntervalSince1970;
    }
}

- (void)setMorningDeparture {
    NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:self.item.minValue];
    NSDateComponents *maxFilterComponent = [DateUtil componentsFromDate:minDate];
    maxFilterComponent.hour = 12;
    maxFilterComponent.minute = 0;
    
    NSDate *filterMaxDepartureTime = [DateUtil dateFromComponents:maxFilterComponent];
    
    self.cellSlider.lowerValue = self.cellSlider.minimumValue;
    self.cellSlider.upperValue = self.cellSlider.maximumValue;
    self.cellSlider.upperValue = filterMaxDepartureTime.timeIntervalSince1970 - self.item.minValue - 60.0;
}

- (void)setDayDeparture {
    NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:self.item.minValue];
    NSDate *maxDate = [NSDate dateWithTimeIntervalSince1970:self.item.maxValue];
    NSDateComponents *minFilterComponent = [DateUtil componentsFromDate:minDate];
    NSDateComponents *maxFilterComponent = [DateUtil componentsFromDate:maxDate];
    
    if (minFilterComponent.hour <= 12) {
        if (minFilterComponent.hour != 12) {
            minFilterComponent.minute = 0;
        }
        minFilterComponent.hour = 12;
    }
    
    if (maxFilterComponent.hour >= 18) {
        if (maxFilterComponent.hour != 18) {
            maxFilterComponent.minute = 0;
        }
        maxFilterComponent.hour = 18;
    }
    
    NSDate *filterMinDepartureTime = [DateUtil dateFromComponents:minFilterComponent];
    NSDate *filterMaxDepartureTime = [DateUtil dateFromComponents:maxFilterComponent];
    
    self.cellSlider.lowerValue = self.cellSlider.minimumValue;
    self.cellSlider.upperValue = self.cellSlider.maximumValue;
    self.cellSlider.lowerValue = filterMinDepartureTime.timeIntervalSince1970 - self.item.minValue;
    self.cellSlider.upperValue = filterMaxDepartureTime.timeIntervalSince1970 - self.item.minValue - 60.0;
}

- (void)setEveningDeparture {
    NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:self.item.minValue];
    NSDateComponents *minFilterComponent = [DateUtil componentsFromDate:minDate];
    minFilterComponent.hour = 18;
    minFilterComponent.minute = 0;
    
    NSDate *filterMinDepartureTime = [DateUtil dateFromComponents:minFilterComponent];
    
    self.cellSlider.lowerValue = self.cellSlider.minimumValue;
    self.cellSlider.upperValue = self.cellSlider.maximumValue;
    self.cellSlider.lowerValue = filterMinDepartureTime.timeIntervalSince1970 - self.item.minValue;
}

@end
