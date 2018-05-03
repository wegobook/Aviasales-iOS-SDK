//
//  JRColorScheme.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <Foundation/Foundation.h>

@interface JRColorScheme : NSObject

+ (UIColor *)colorFromConstant:(NSString *)textColorConstant;

// Base
+ (UIColor *)mainColor;
+ (UIColor *)actionColor;

// SearchForm
+ (UIColor *)searchFormTintColor;
+ (UIColor *)searchFormBackgroundColor;
+ (UIColor *)searchFormTextColor;

// Background
+ (UIColor *)mainBackgroundColor;
+ (UIColor *)lightBackgroundColor;
+ (UIColor *)darkBackgroundColor;
+ (UIColor *)itemsBackgroundColor;
+ (UIColor *)itemsSelectedBackgroundColor;

// PriceCalendar
+ (UIColor *)priceCalendarBarColor;
+ (UIColor *)priceCalendarSelectedBarColor;
+ (UIColor *)priceCalendarMinBarColor;
+ (UIColor *)priceCalendarSelectedMinBarColor;
+ (UIColor *)priceCalendarMinPriceLevelColor;
+ (UIColor *)priceCalendarResultCellCheapestViewBackgroundColor;

// Slider
+ (UIColor *)sliderBackgroundColor;

//Text
+ (UIColor *)darkTextColor;
+ (UIColor *)lightTextColor;
+ (UIColor *)inactiveLightTextColor;

// Separator
+ (UIColor *)separatorLineColor;

// Button
+ (UIColor *)buttonBackgroundColor;
+ (UIColor *)buttonSelectedBackgroundColor;

// Rating stars
+ (UIColor *)ratingStarDefaultColor;
+ (UIColor *)ratingStarSelectedColor;

// Filters
+ (UIImage *)sliderMinImage;
+ (UIImage *)sliderMaxImage;

+ (UIColor *)photoActivityIndicatorBackgroundColor;
+ (UIColor *)photoActivityIndicatorBorderColor;

// Hotels
+ (UIColor *)hotelBackgroundColor;
+ (UIColor *)discountColor;
+ (UIColor *)priceBackgroundColor;

#pragma mark - Hotel details
+ (UIColor *)ratingColor:(NSInteger)rating;

@end
