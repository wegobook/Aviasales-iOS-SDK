//
//  JRColorScheme.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRColorScheme.h"

#define COLOR_WITH_WHITE(A) [[UIColor alloc] initWithWhite : ((float)A/255.0f)alpha : 1]
#define COLOR_WITH_RED(A, B, C) COLOR_WITH_ALPHA(A, B, C, 1)
#define COLOR_WITH_ALPHA(A, B, C, D) [[UIColor alloc] initWithRed : (float)A/255.0f green : (float)B/255.0f blue : (float)C/255.0f alpha : (float)D]
#define COLOR_WITH_PATTERN(A) [[UIColor alloc] initWithPatternImage :[UIImage imageNamed:A]]

/**
 * H - 0..255
 * S - 0..100
 * B - 0..100
 */
#define COLOR_WITH_HUE(H, S, B) COLOR_WITH_HSBA(H, S, B, 1)
#define COLOR_WITH_HSBA(H, S, B, A) [UIColor colorWithHue:H/360.f saturation:S/100.f brightness:B/100.f alpha:A]

@implementation JRColorScheme

+ (UIColor *)colorFromConstant:(NSString *)textColorConstant {
    NSParameterAssert(![textColorConstant isEqualToString:@"colorFromConstant"]);

    UIColor *result;

    SEL selector = NSSelectorFromString(textColorConstant);
    if ([self respondsToSelector: selector]) {
        IMP imp = [self methodForSelector:selector];
        UIColor* (*func)(id, SEL) = (void *)imp;
        result = func(self, selector);
    } else {
        NSLog(@"tried to create color with unsupported constant %@", textColorConstant);
    }
    return result;
}

#pragma mark - Base

+ (UIColor *)mainColor {
    return [ColorSchemeManager shared].current.mainColor;
}

+ (UIColor *)actionColor {
    return [ColorSchemeManager shared].current.actionColor;
}

#pragma mark - Form

+ (UIColor *)searchFormTintColor {
    return [ColorSchemeManager shared].current.formTintColor;
}

+ (UIColor *)searchFormBackgroundColor {
    return [ColorSchemeManager shared].current.formBackgroundColor;
}

+ (UIColor *)searchFormTextColor {
    return [ColorSchemeManager shared].current.formTextColor;
}

#pragma mark - Slider

+ (UIColor *)sliderBackgroundColor {
    return COLOR_WITH_RED(236, 239, 241);
}

#pragma mark - PriceCalendar

+ (UIColor *)priceCalendarBarColor {
    return COLOR_WITH_ALPHA(115, 135, 174, 0.2);
}

+ (UIColor *)priceCalendarSelectedBarColor {
    return COLOR_WITH_ALPHA(115, 135, 174, 0.6);
}

+ (UIColor *)priceCalendarMinBarColor {
    return COLOR_WITH_ALPHA(110, 211, 33, 0.2);
}

+ (UIColor *)priceCalendarSelectedMinBarColor {
    return COLOR_WITH_ALPHA(110, 211, 33, 0.6);
}

+ (UIColor *)priceCalendarMinPriceLevelColor {
    return [self priceCalendarMinBarColor];
}

+ (UIColor *)priceCalendarResultCellCheapestViewBackgroundColor {
    return [UIColor colorWithCSS: @"#3BD17A"];
}

#pragma mark - Background

+ (UIColor *)mainBackgroundColor {
    return COLOR_WITH_RED(247, 247, 247);
}

+ (UIColor *)lightBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)darkBackgroundColor {
    return COLOR_WITH_HUE(0, 0, 82);
}

+ (UIColor *)itemsBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)itemsSelectedBackgroundColor {
    return COLOR_WITH_WHITE(230);
}

+ (UIColor *)darkTextColor {
    return COLOR_WITH_HUE(0, 0, 38);
}

+ (UIColor *)lightTextColor {
    return COLOR_WITH_HUE(0, 0, 67);
}

+ (UIColor *)inactiveLightTextColor {
    return COLOR_WITH_HUE(0, 0, 66);
}

+ (UIColor *)separatorLineColor {
    return COLOR_WITH_HUE(0, 0, 59);
}

+ (UIColor *)buttonBackgroundColor {
    return COLOR_WITH_HUE(0, 0, 85);
}

+ (UIColor *)buttonSelectedBackgroundColor {
    return COLOR_WITH_HUE(0, 0, 80);
}

+ (UIColor *)ratingStarDefaultColor {
    return COLOR_WITH_ALPHA(255, 155, 16, 0.4);
}

+ (UIColor *)ratingStarSelectedColor {
    return COLOR_WITH_RED(255, 154, 13);
}

// Filters

+ (UIImage *)sliderMinImage {
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
    return [[[UIImage imageNamed:@"JRSliderMinImg"] imageTintedWithColor:[self darkBackgroundColor]] resizableImageWithCapInsets:insets];
}

+ (UIImage *)sliderMaxImage {
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
    return [[[UIImage imageNamed:@"JRSliderMaxImg"] imageTintedWithColor:[self mainColor]] resizableImageWithCapInsets:insets];
}

+ (UIColor *)photoActivityIndicatorBackgroundColor
{
    return UIColor.clearColor;
}

+ (UIColor *)photoActivityIndicatorBorderColor
{
    return [self actionColor];
}

#pragma mark - Hotel details
+ (UIColor *)ratingColor:(NSInteger)rating
{
    if (rating < 65) {
        return [self ratingRedColor];
    } else if (rating <= 75) {
        return [self ratingYellowColor];
    } else {
        return [self ratingGreenColor];
    }
}

+ (UIColor *)ratingGreenColor
{
    return [UIColor colorWithRed:25.0/255.0 green:154.0/255.0 blue:17.0/255.0 alpha:1.0];
}

+ (UIColor *)ratingRedColor
{
    return [UIColor colorWithRed:243.0/255.0 green:113.0/255.0 blue:89.0/255.0 alpha:1.0];
}

+ (UIColor *)ratingYellowColor
{
    return [UIColor colorWithRed:245.0/255.0 green:166.0/255.0 blue:35.0/255.0 alpha:1.0];
}

#pragma mark - Hotels

+ (UIColor *)hotelBackgroundColor
{
    return [self priceBackgroundColor];
}

+ (UIColor *)discountColor
{
    return [UIColor colorWithRed:0.0 green:166.0/255.0 blue:244.0/255.0 alpha:1];
}

+ (UIColor *)priceBackgroundColor
{
    return [UIColor colorWithRed:70.0/255.0 green:71.0/255.0 blue:72.0/255.0 alpha:1];
}

@end
