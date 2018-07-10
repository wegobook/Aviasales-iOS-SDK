//
//  JRFilterOneThumbSliderItem.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRFilterOneThumbSliderItem.h"

#import "DateUtil.h"


@implementation JRFilterOneThumbSliderItem

- (instancetype)initWithMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue currentValue:(CGFloat)currentValue {
    self = [super init];
    if (self) {
        _minValue = minValue;
        _maxValue = maxValue;
        _currentValue = currentValue;
    }
    
    return self;
}

#pragma - mark JRFilterItemProtocol

- (NSString *)title {
    return @"";
}

- (NSAttributedString *)attributedStringValue {
    return [[NSAttributedString alloc] initWithString:@""];
}

@end


@implementation JRFilterPriceItem

#pragma - mark JRFilterItemProtocol

- (NSString *)title {
    return NSLS(@"JR_FILTER_PRICE_FILTER");
}

- (NSAttributedString *)attributedStringValue {
    JRSDKPrice *price = [JRSDKPrice priceWithCurrency:USD_CURRENCY value:self.currentValue];
    NSString *priceString = [price formattedPriceinUserCurrency];
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLS(@"JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO"), priceString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    return attributedText;
}

@end


@implementation JRFilterTotalDurationItem

#pragma - mark JRFilterItemProtocol

- (NSString *)title {
    return NSLS(@"JR_FILTER_TOTAL_DURATION");
}

- (NSAttributedString *)attributedStringValue {
    NSString *timeString = [DateUtil duration:self.currentValue durationStyle:JRDateUtilDurationLongStyle];
    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLS(@"JR_FILTER_TOTAL_DURATION_PRIOR_UP_TO"), timeString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    return attributedText;
}

@end
